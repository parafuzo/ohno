defmodule Fabion.Sources do

  @adapter Keyword.get(
             Application.get_env(:fabion, __MODULE__),
             :adapter,
             Fabion.Sources.GithubAdapter
           )

  alias Fabion.Repo
  alias Fabion.Sources.Repository

  def statuses(repo, commit_sha, parameters) do
    @adapter.client()
    |> @adapter.statuses(repo, commit_sha, parameters)
  end

  def get_file(repo, commit_sha, path) do
    @adapter.client()
    |> @adapter.get_file(repo, commit_sha, path)
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

  def repo_by_url(url) do
    with {:ok, github_repo} <- parse_repo(url),
         %Repository{} = repo <- Repo.get_by(Repository, github_repo: github_repo) do
      {:ok, repo}
    else
      _ ->
        {:error, "#{url} repository not registered in the service"}
    end
  end

  def parse_repo(<<"https://github.com/", repo::binary>>) do
    {:ok, repo}
  end

  def parse_repo(_), do: {:error, :invalid_repo}
end
