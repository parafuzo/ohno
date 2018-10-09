defmodule Ohno.CloudBuild do
  @adapter Keyword.get(
             Application.get_env(:ohno, __MODULE__),
             :adapter,
             __MODULE__.GCloudAdpter
           )

  import Logger
  import Indifferent.Sigils
  import ShorterMaps

  alias Ohno.Repo
  alias Ohno.CloudBuild.Client
  alias Ohno.Builder
  alias Ohno.Builder.{Job, Pipeline}
  alias Ohno.Sources

  alias Ohno.Enqueuer
  alias Ohno.Builder.ProcessJob

  @requee_status [:NEW, :QUEUED, :WORKING]

  def update_job_status(%Job{status: status} = job) when status not in @requee_status do
    {:ok, job}
  end

  def update_job_status(%Job{status: :NEW} = job) do
    {job, %Client{} = client} = get_client_for_job(job)
    %Job{stage: %{cloudbuild: cloudbuild, pipeline: pipeline}} = job
    refs = pipeline |> Pipeline.get_refs()

    client
    |> @adapter.build_create(refs, cloudbuild)
    |> set_queued(job)
  end

  def update_job_status(%Job{} = job) do
    {%Job{gcloud_build_id: gcloud_build_id} = job, %Client{} = client} = get_client_for_job(job)

    client
    |> @adapter.build_get(gcloud_build_id)
    |> update_status(job)
  end

  defp get_client_for_job(%Job{stage: %{pipeline: ~M{repository}}} = job) do
    {job, @adapter.new_repo(repository)}
  end

  defp get_client_for_job(%Job{} = job) do
    job
    |> Repo.preload(stage: [pipeline: [:repository]])
    |> get_client_for_job()
  end

  defp set_queued({:ok, operation}, job) do
    update_job(job, %{
      status: :QUEUED,
      gcloud_build_id: ~i(operation.metadata.build.id)
    })
  end

  defp set_queued(result, _), do: result

  defp update_status({:ok, %{status: status}}, job) do
    update_job(job, %{status: String.to_atom(status)})
  end

  defp update_job(job, attrs) do
    job
    |> Job.changeset(attrs)
    |> case do
      %{changes: changes} = changeset when changes != %{} ->
        changeset
        |> Repo.update!()
        |> notify_job_status!()
      _ ->
        job
    end
    |> re_queue()
  end

  defp re_queue(%Job{status: status} = job) when status in @requee_status do
    Enqueuer.push({ProcessJob, job})
    {:ok, job}
  end

  defp re_queue(%Job{stage: %{pipeline: pipeline}} = job) do
    Builder.make_jobs(pipeline)
    {:ok, job}
  end

  def notify_job_status!(
    %Job{stage: %{
      name: stage_name, pipeline: %{repository: repository} = pipeline
    }} = job
  ) do
    refs = pipeline |> Pipeline.get_refs()
    %{github_repo: github_repo} = repository
    state = Sources.job_state(job)

    {:ok, _} = Sources.statuses(github_repo, refs, %{
      state: state,
      # target_url: "https://77003720.ngrok.io/#{github_repo}/#{job.id}",
      target_url: "#{Sources.target_url}/#{github_repo}/#{job.id}",
      context: "ohno/#{stage_name}"
    })

    info("New job status notified in #{github_repo}: #{inspect(job)}")

    job
  end
end

