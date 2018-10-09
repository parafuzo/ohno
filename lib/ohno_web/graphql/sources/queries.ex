defmodule OhnoWeb.Graphql.Sources.Queries do
  use OhnoWeb.Graphql
  alias OhnoWeb.Graphql.Sources.Resolvers

  object :sources_queries do
    field(:repository, :repository) do
      arg(:id, non_null(:id))

      middleware Absinthe.Relay.Node.ParseIDs, id: [:repository]
      resolve(&Resolvers.get_repository/2)
    end

    connection field(:repositories, node_type: :repository) do
      resolve(&Resolvers.all_repositories/2)
    end
  end
end
