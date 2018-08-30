defmodule FabionWeb.Graphql do
  alias __MODULE__

  def graphql do
    quote do
      use Absinthe.Schema.Notation
      use Absinthe.Relay.Schema.Notation, :modern
      use Absinthe.Ecto, repo: Fabion.Repo
      import Graphql.Helpers

      alias Fabion.Repo
    end
  end

  def resolver do
    quote do
      alias Absinthe.Relay.Connection
      alias Absinthe.Resolution
      alias Fabion.Repo

      import Graphql.Helpers

      import Ecto
      import Ecto.Query
    end
  end

  @doc """
  When used, dispatch to the appropriate graphql/resolver.
  """
  defmacro __using__([]) do
    apply(__MODULE__, :graphql, [])
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
