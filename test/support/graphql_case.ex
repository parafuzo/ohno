defmodule FabionWeb.GraphqlCase do
  use ExUnit.CaseTemplate

  alias FabionWeb.Graphql.Schema
  alias Absinthe.Relay.Node

  using do
    quote do
      alias FabionWeb.Graphql.Schema

      # syntax sugar
      import PipeTo
      import ShorterMaps

      import unquote(__MODULE__)
      import Fabion.Factories

      alias Fabion.Repo
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Fabion.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Fabion.Repo, {:shared, self()})
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

  def run_graphql!(query, options \\ [], schema \\ Schema) do
    case run_graphql(query, options, schema) do
      {:ok, result} -> result
      {:error, error} -> throw error
    end
  end

  defmacro get_query(file) do
    quote do
      file = unquote(file)
      File.read!(Path.join(__DIR__, "#{file}.graphql"))
    end
  end

  def jq(target, query) do
    Jqish.run(target, query)
  end

  def jq!(target, query) do
    case jq(target, query) do
      {:ok, result} -> result
      {:error, error} ->
        throw error
    end
  end
end
