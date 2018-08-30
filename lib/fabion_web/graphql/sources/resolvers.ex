defmodule FabionWeb.Graphql.Sources.Resolvers do
  use FabionWeb.Graphql, :resolver

  alias Fabion.Sources

  def all_repositories(pagination_args, _info) do
    Sources.query_repositories() |> paginate(pagination_args)
  end
end
