defmodule Fabion.Sources.ProcessEventJob do
  import ShorterMaps

  alias Fabion.Repo
  alias Fabion.Sources
  alias Fabion.Sources.RepositoryEvent

  def perform(event_id) do
    {:ok, event} = get_repository_event(event_id)
    %{repository: ~M{github_repo}, params: %{
      "head_commit" => %{
        "id" => commit_sha
      }
    }} = event

    case Sources.get_file(github_repo, commit_sha, "./fabion.yaml") do
      {:ok, content} ->
        IO.inspect(%{ content: content })
        :ok
      error -> error
    end
  end

  defp get_repository_event(id) do
    case Repo.get(RepositoryEvent, id) do
      %RepositoryEvent{} = r -> {:ok, r |> Repo.preload(:repository)}
      _ -> {:error, :not_found}
    end
  end
end
