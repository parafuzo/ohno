defmodule Fabion.Sources do
  import ShorterMaps

  @adapter Keyword.get(
             Application.get_env(:fabion, __MODULE__),
             :adapter,
             Fabion.Sources.GithubAdapter
           )

  alias Fabion.Repo
  alias Fabion.Accounts
  alias Fabion.Sources.Repository
  alias Fabion.Sources.RepositoryEvent
  alias Fabion.Enqueuer
  alias Fabion.Sources.ProcessEventJob

  def statuses(repo, commit_sha, parameters) do
    @adapter.client()
    |> @adapter.statuses(repo, commit_sha, parameters)
  end

  def add_event("push", %{"repository" => ~m{url}, "sender" => sender} = params) do
    with {:ok, %{id: repository_id}} <- repo_by_url(url),
         {:ok, %{id: sender_id}} <- Accounts.user_from_sender(sender),
         {:ok, ~M{id} = event} <-
           ~M{type: :PUSH, repository_id, sender_id, params}
           |> RepositoryEvent.changeset()
           |> Repo.insert(),
         {:ok, _} <- Enqueuer.push({ProcessEventJob, id}) do
      {:ok, event}
    end
  end

  def add_repository(attrs) do
    attrs
    |> Repository.changeset()
    |> Repo.insert()
  end

  def get_repository(id) do
    case Repo.get(Repository, id) do
      %Repository{} = r -> {:ok, r}
      _ -> {:error, :not_found}
    end
  end

  def query_repositories() do
    Fabion.Sources.Repository
  end

  defp repo_by_url(url) do
    with {:ok, github_repo} <- parse_repo(url),
         %Repository{} = repo <- Repo.get_by(Repository, github_repo: github_repo) do
      {:ok, repo}
    else
      _ ->
        {:error, "#{url} repository not registered in the service"}
    end
  end

  defp parse_repo(<<"https://github.com/", repo::binary>>) do
    {:ok, repo}
  end

  defp parse_repo(_), do: {:error, :invalid_repo}
end
