defmodule Ohno.BuilderTest do
  use Ohno.DataCase, async: true

  alias Ohno.Builder
  import GenQueue.Test
  alias Ohno.Enqueuer
  alias Ohno.Builder.GetStagesJob
  alias Ohno.Builder.ProcessJob

  setup do
    setup_test_queue(Enqueuer)
  end

  describe "there is a repository in the database" do
    setup do
      {:ok, ~M{github_repo} = repo} =
        params_with_assocs(:repository)
        |> Ohno.Sources.add_repository()

      url = "https://github.com/#{github_repo}"

      push_params =
        read_file_event!("push_commit")
        |> Map.update!("repository", &Map.put(&1, "url", url))

      ~M{repo, push_params}
    end

    test "make a pipeline from a push_event and params", ~M{repo, push_params} do
      {:ok, pipeline} = Builder.add_pipeline("push", push_params)

      pipeline = pipeline |> Repo.preload(:sender)

      assert pipeline.repository_id == repo.id
      assert pipeline.sender_id != nil
      assert pipeline.sender.node_id == get_in(push_params, ["sender", "node_id"])
      assert pipeline.from_type == :PUSH_EVENT
      assert pipeline.params == push_params
    end

    test "enquee pipeline to make stages", ~M{push_params} do
      {:ok, %{id: id}} = Builder.add_pipeline("push", push_params)
      assert_receive(%GenQueue.Job{module: GetStagesJob, args: [^id]})
    end
  end

  describe "with stages in a pipeline" do
    setup do
      pipeline = pipeline_with_params(:PUSH_EVENT, "push_commit")
      ~M{pipeline}
    end

    test "make jobs for first stage", ~M{pipeline} do
      release = insert(:stage, ~M{pipeline, name: "release", stage_group: "release"})
      test1 = insert(:stage, ~M{pipeline})
      test2 = insert(:stage, ~M{pipeline})

      assert pipeline.id == release.pipeline_id
      assert pipeline.id == test1.pipeline_id
      assert pipeline.id == test2.pipeline_id

      {:ok, [job1, job2]} = Builder.make_jobs(pipeline)
      assert job1.status == :NEW
      assert job1.stage_id == test1.id
      assert job2.status == :NEW
      assert job2.stage_id == test2.id

      Builder.set_status!(job1, :SUCCESS)
      Builder.set_status!(job2, :WORKING)

      {:ok, []} = Builder.make_jobs(pipeline)

      Builder.set_status!(job2, :SUCCESS)

      {:ok, [job]} = Builder.make_jobs(pipeline)
      assert job.stage_id == release.id
      assert job.status == :NEW

      Builder.set_status!(job, :SUCCESS)
      {:ok, []} = Builder.make_jobs(pipeline)
    end

    test "enquee jobs to run", ~M{pipeline} do
      insert(:stage, ~M{pipeline})
      insert(:stage, ~M{pipeline})

      {:ok, [job1, job2]} = Builder.make_jobs(pipeline)
      assert_receive(%GenQueue.Job{module: ProcessJob, args: [^job1]})
      assert_receive(%GenQueue.Job{module: ProcessJob, args: [^job2]})
    end

    test "not make job for manual stage", ~M{pipeline} do
      %{} = insert(:stage, ~M{pipeline, when: :MANUAL})
      {:ok, []} = Builder.make_jobs(pipeline)
    end
  end
end
