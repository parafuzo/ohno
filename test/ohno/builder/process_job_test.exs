defmodule Ohno.Builder.ProcessJobTest do
  use Ohno.DataCase, async: false

  import Mox

  import GenQueue.Test
  alias Ohno.Enqueuer
  alias Ohno.Builder.ProcessJob

  alias Ohno.Builder
  alias Ohno.Builder.{Job, Pipeline}
  alias Ohno.CloudBuild.MockAdapter
  alias Ohno.CloudBuild.Client
  alias Ohno.MockSourcesAdapter

  setup do
    setup_test_queue(Enqueuer)
  end

  setup do
    ~M{repository} = pipeline = pipeline_with_params(:PUSH_EVENT, "push_commit")
    cloudbuild = priv_yaml_file!("fixtures", "stage_test")
    stage = insert(:stage, ~M{pipeline, cloudbuild})

    {:ok, [job]} = Builder.make_jobs(pipeline)

    client = %Client{
      adapter: MockAdapter,
      repository: repository,
      client: %{}
    }

    stub(MockAdapter, :new_repo, fn ^repository -> client end)
    stub(MockSourcesAdapter, :client, fn -> :client end)

    ~M{job, client, stage, pipeline, cloudbuild, repository}
  end

  setup :verify_on_exit!

  test "create a cloud build from a new job", context do
    ~M{client, job, pipeline, cloudbuild} = context
    build_id = Ecto.UUID.generate()
    refs = pipeline |> Pipeline.get_refs()

    expect(MockAdapter, :build_create, fn ^client, ^refs, ^cloudbuild ->
      {:ok, %{ metadata: %{ build: %{ id: build_id }}}}
    end)

    mock_statuses("pending", refs, context)

    {:ok, %Job{} = job} = ProcessJob.perform(job)
    assert job.status == :QUEUED
    assert job.gcloud_build_id == build_id

    assert_receive(%GenQueue.Job{module: ProcessJob, args: [^job]})
  end

  describe "with job queued in cloud build" do
    setup ~M{job} do
      build_id = Ecto.UUID.generate()
      job = Job.changeset(job, %{
        status: :QUEUED,
        gcloud_build_id: build_id,
      }) |> Repo.update!

      ~M{job, build_id}
    end

    test "re-queue work to update your status", context do
      ~M{client, job, pipeline, build_id} = context
      refs = pipeline |> Pipeline.get_refs()
      mock_statuses("pending", refs, context, 0)

      expect(MockAdapter, :build_get, fn
        ^client, ^build_id -> {:ok, %{ status: "QUEUED" }}
      end)

      {:ok, %Job{} = job} = ProcessJob.perform(job)
      assert job.status == :QUEUED
      assert_receive(%GenQueue.Job{module: ProcessJob, args: [^job]})
    end

    test "update job, notify and re-queue", context do
      ~M{client, job, pipeline, build_id} = context
      refs = pipeline |> Pipeline.get_refs()
      mock_statuses("pending", refs, context)

      expect(MockAdapter, :build_get, fn
        ^client, ^build_id -> {:ok, %{ status: "WORKING" }}
      end)

      {:ok, %Job{} = job} = ProcessJob.perform(job)
      assert job.status == :WORKING
      assert_receive(%GenQueue.Job{module: ProcessJob, args: [^job]})
    end

    test "update job, notify and not re-queue", context do
      ~M{client, job, pipeline, build_id} = context
      refs = pipeline |> Pipeline.get_refs()
      mock_statuses("success", refs, context)

      expect(MockAdapter, :build_get, fn
        ^client, ^build_id -> {:ok, %{ status: "SUCCESS" }}
      end)

      {:ok, %Job{} = job} = ProcessJob.perform(job)
      assert job.status == :SUCCESS

      refute_received(%GenQueue.Job{module: ProcessJob, args: [^job]})
    end

    test "make new job for next stages", context do
      ~M{client, job, pipeline, build_id, cloudbuild} = context
      %{id: release_stage_id} = insert(:stage, ~M{name: "release", pipeline, cloudbuild})

      refs = pipeline |> Pipeline.get_refs()
      mock_statuses("success", refs, context)

      expect(MockAdapter, :build_get, fn
        ^client, ^build_id -> {:ok, %{ status: "SUCCESS" }}
      end)

      {:ok, %Job{} = job} = ProcessJob.perform(job)
      assert job.status == :SUCCESS

      refute_received(%GenQueue.Job{module: ProcessJob, args: [^job]})
      assert_received(%GenQueue.Job{module: ProcessJob, args: [%{stage_id: ^release_stage_id}]})
    end

    test "do not do anything", context do
      ~M{client, job, pipeline, build_id} = context
      refs = pipeline |> Pipeline.get_refs()
      mock_statuses("success", refs, context, 0)

      expect(MockAdapter, :build_get, 0, fn
        ^client, ^build_id -> {:ok, %{ status: "SUCCESS" }}
      end)

      job = Job.changeset(job, %{
        status: :SUCCESS,
        gcloud_build_id: build_id,
      }) |> Repo.update!

      {:ok, %Job{} = job} = ProcessJob.perform(job)
      assert job.status == :SUCCESS

      refute_received(%GenQueue.Job{module: ProcessJob, args: [^job]})
    end
  end

  defp mock_statuses(state, refs, ~M{stage, repository, job}, count \\ 1) do
    ~M{github_repo} = repository
    # TODO: Adding host in target_url
    params = %{
      state: state,
      target_url: "#{Ohno.Sources.target_url}/#{repository.github_repo}/#{job.id}",
      context: "ohno/#{stage.name}"
    }
    expect(MockSourcesAdapter, :statuses, count, fn
      :client, ^github_repo, ^refs, ^params ->
        {:ok, %{}}
    end)
  end
end
