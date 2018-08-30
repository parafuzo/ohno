defmodule Fabion.Sources do
  alias Fabion.Repo
  alias Fabion.Sources.Repository

  def add_repository(attrs) do
    attrs
    |> Repository.changeset()
    |> Repo.insert()
  end

  def query_repositories() do
    Fabion.Sources.Repository
  end
end
