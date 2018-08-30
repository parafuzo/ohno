defmodule FabionWeb.Graphql.Sources.Queries do
  use FabionWeb.Graphql
  alias FabionWeb.Graphql.Sources.Resolvers

  object :sources_queries do
    connection field(:repositories, node_type: :repository) do
      resolve(&Resolvers.all_repositories/2)
    end
  end
end
