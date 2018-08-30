defmodule FabionWeb.Graphql.Types.Node do
  @moduledoc """
  Provides a Node Type for use in a GraphQL Schema. This is required by any
  Relay-compliant server as Relay needs to refetch items by a base64-encoded
  id.
  """

  use FabionWeb.Graphql, :graphql

  alias Fabion.Sources

  node interface do
    resolve_type(fn
      # Sources
      %Sources.Repository{}, _ -> :repository
    end)
  end
end
