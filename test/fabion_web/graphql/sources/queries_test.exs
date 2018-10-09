defmodule FabionWeb.Graphql.Sources.QueriesTest do
  use FabionWeb.GraphqlCase, async: true

  describe to_string(FabionWeb.Graphql.Sources.Queries) do
    setup do
      {:ok, repo} =
        params_with_assocs(:repository)
        |> Fabion.Sources.add_repository()

      ~M{repo}
    end

    test "try get repositories", ~M{repo} do
      ~M{data} = run_graphql!(:repositories)
      id = jq!(data, ".repositories.edges.[0].node.id") |> from_global_id!()
      assert id == %{type: :repository, id: repo.id}
      assert length(jq!(data, ".repositories.edges")) == 1
      assert jq!(data, ".repositories.edges.[0].node.github_repo") == repo.github_repo
    end

    test "get repository by id", ~M{repo} do
      id = to_global_id(:repository, repo.id)
      ~M{data} = run_graphql!(:repository, variables: ~m{id})
      id = jq!(data, ".repository.id") |> from_global_id!()
      assert id == %{type: :repository, id: repo.id}
      assert jq!(data, ".repository.github_repo") == repo.github_repo
    end
  end
end
