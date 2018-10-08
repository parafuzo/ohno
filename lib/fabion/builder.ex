defmodule Fabion.Builder do
  import ShorterMaps

  require Logger
  import Ecto.Query

  alias Fabion.Repo
  alias Fabion.Accounts
  alias Fabion.Sources
  alias Fabion.Builder.Pipeline
  alias Fabion.Builder.Stage
  alias Fabion.Builder.Job

  alias Fabion.Enqueuer
  alias Fabion.Builder.GetStagesJob
  alias Fabion.Builder.ProcessJob

  def add_pipeline("push", %{"repository" => ~m{url}, "sender" => sender} = params) do
    with {:ok, %{id: repository_id}} <- Sources.repo_by_url(url),
         {:ok, %{id: sender_id}} <- Accounts.user_from_sender(sender),
         {:ok, ~M{id} = pipeline} <-
           ~M{from_type: :PUSH_EVENT, repository_id, sender_id, params}
           |> Pipeline.changeset()
           |> Repo.insert(),
         {:ok, _} <- Enqueuer.push({GetStagesJob, id}) do
      Logger.info("Adding pipeline #{inspect(pipeline)}")
      {:ok, pipeline}
    end
  end

  def set_status!(%Job{} = job, new_status) do
    Job.changeset(job, %{status: new_status}) |> Repo.update!()
  end

  def make_jobs(%Pipeline{id: id, stages_groups: stages_groups}) do
    with stage_by_groups <- stages_by_group_with_jobs(id),
         group <- next_or_current_group(stage_by_groups, stages_groups),
         {:ok, jobs} when jobs != [] <- create_jobs(group, stage_by_groups) do
      for job <- jobs do
        Enqueuer.push({ProcessJob, job})
      end

      {:ok, jobs}
    end
  end

  defp stages_by_group_with_jobs(pipeline_id) do
    from(s in Stage,
      left_join: j in assoc(s, :jobs),
      where: s.pipeline_id == ^pipeline_id,
      preload: [jobs: j],
      order_by: [s.inserted_at, j.inserted_at]
    )
    |> Repo.all()
    |> Enum.group_by(&Map.get(&1, :stage_group))
  end

  defp insert_job!(%Stage{id: stage_id, jobs: []} = stage) do
    %Job{stage: stage}
    |> Job.changeset(%{ stage_id: stage_id })
    |> Repo.insert!()
  end

  defp next_or_current_group(stage_by_groups, stages_groups) do
    stages_groups
    # Only have a stages
    |> Enum.filter(&Map.has_key?(stage_by_groups, &1))
    # Find current execute or next
    |> Enum.find(fn group ->
      !(stage_by_groups |> Map.get(group) |> Enum.all?(&Stage.success?(&1)))
    end)
  end

  defp create_jobs(nil, _), do: {:ok, []}

  defp create_jobs(group, stage_by_groups) do
    stages = Map.get(stage_by_groups, group)

    Repo.transaction(fn ->
      # Only create jobs if not have any one
      for stage <- stages, filter_stage(stage) do
        insert_job!(stage)
      end
    end)
  end

  defp filter_stage(%Stage{when: :MANUAL}), do: false
  defp filter_stage(%Stage{jobs: jobs}), do: jobs == []

end
