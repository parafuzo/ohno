defmodule Fabion.Builder.GetStagesJob do
  import ShorterMaps

  alias Fabion.Repo
  alias Fabion.Sources
  alias Fabion.Builder.Pipeline

  def perform(pipeline_id) do
    {:ok, pipeline} = get_pipeline(pipeline_id)
    %{repository: ~M{github_repo}, params: %{
      "head_commit" => %{
        "id" => commit_sha
      }
    }} = pipeline

    case Sources.get_file(github_repo, commit_sha, "./fabion.yaml") do
      {:ok, content} ->
        IO.inspect(%{ content: content })
        :ok
      error -> error
    end
  end

  defp get_pipeline(id) do
    case Repo.get(Pipeline, id) do
      %Pipeline{} = r -> {:ok, r |> Repo.preload(:repository)}
      _ -> {:error, :not_found}
    end
  end
end
