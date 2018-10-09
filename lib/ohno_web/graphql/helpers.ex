defmodule OhnoWeb.Graphql.Helpers do
  alias Absinthe.Relay
  alias Ohno.Repo

  @doc """
  Paginate results for Ecto query with relay pagination args
  """
  def paginate(query, pagination_args) do
    with {:ok, data} <- Relay.Connection.from_query(query, &Repo.all/1, pagination_args) do
      total_count = Repo.aggregate(query, :count, :id)
      {:ok, data |> Map.put(:total_count, total_count)}
    else
      err -> err
    end
  end
end
