defmodule OhnoWeb.Graphql.Sources.Resolvers do
  use OhnoWeb.Graphql, :resolver

  alias Ohno.Sources

  def all_repositories(pagination_args, _info) do
    Sources.query_repositories() |> paginate(pagination_args)
  end

  def get_repository(%{id: %{id: id}}, _info) do
    Sources.get_repository(id)
  end
end
