defmodule OhnoWeb.GraphqlCase do
  use ExUnit.CaseTemplate

  alias OhnoWeb.Graphql.Schema
  alias Absinthe.Relay.Node

  using do
    quote do
      alias OhnoWeb.Graphql.Schema

      # syntax sugar
      import PipeTo
      import ShorterMaps

      import unquote(__MODULE__)
      import Ohno.Factories
      import Ohno.Support.Helpers

      alias Ohno.Repo
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ohno.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Ohno.Repo, {:shared, self()})
    end
    :ok
  end

  def to_global_id(node_type, source_id, schema \\ Schema) do
    Node.to_global_id(node_type, source_id, schema)
  end

  def from_global_id!(global_id, schema \\ Schema) do
    case Node.from_global_id(global_id, schema) do
      {:ok, result} -> result
      {:error, error} -> throw error
    end
  end

  def run_graphql(query, options \\ [], schema \\ Schema) do
    Absinthe.run(query, schema, options)
  end

  def run_graphql!(query, options \\ [], schema \\ Schema)

  def run_graphql!(query, options, schema) when is_atom(query) do
    query = get_query!(to_string(query))
    run_graphql!(query, options, schema)
  end

  def run_graphql!(query, options, schema) do
    case run_graphql(query, options, schema) do
      {:ok, result} -> result
      {:error, error} -> throw error
    end
  end

  def get_query!(file) do
    dir = [__DIR__, "..", "..", "priv", "queries"]
      |> Path.join()
      |> Path.expand()

    File.read!(Path.join(dir, "#{file}.graphql"))
    <> File.read!(Path.join(dir, "fragments.graphql"))
  end
end
