defmodule Fabion.Sources do
  @adapter Keyword.get(Application.get_env(:fabion, __MODULE__), :adapter, Fabion.Sources.GithubAdapter)

  alias Fabion.Repo
  alias Fabion.Sources.Repository

  defdelegate statuses(repo, commit_sha, parameters), to: @adapter

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
end
