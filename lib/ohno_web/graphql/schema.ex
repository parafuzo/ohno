defmodule OhnoWeb.Graphql.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias OhnoWeb.Graphql

  # Scalar
  import_types(Graphql.Types.Scalars)

  # Relay
  import_types(Graphql.Types.Node)

  # Sources
  import_types(Graphql.Sources.Types)
  import_types(Graphql.Sources.Queries)
  # import_types Graphql.Sources.Mutations

  query do
    import_fields(:sources_queries)
  end

  # mutation do
  #   import_fields :sources_mutations
  # end
end
