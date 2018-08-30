defmodule FabionWeb.Graphql.Sources.QueriesTest do
  use FabionWeb.GraphqlCase, async: true

  @query get_query("queries")

  describe to_string(FabionWeb.Graphql.Sources.Queries) do
    test "try get repositories" do
      {:ok, repo} =
        params_with_assocs(:repository)
        |> Fabion.Sources.add_repository()

      ~M{data} = run_graphql!(@query)
      id = jq!(data, ".repositories.edges.[0].node.id") |> from_global_id!()
      assert id == %{type: :repository, id: repo.id}
      assert length(jq!(data, ".repositories.edges")) == 1
      assert jq!(data, ".repositories.edges.[0].node.github") == repo.github
    end
  end
end
