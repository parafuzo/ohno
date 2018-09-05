defmodule Fabion.Sources do
  alias Fabion.Repo
  alias Fabion.Sources.Repository

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
