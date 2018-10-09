defmodule FabionWeb.Graphql.Sources.Types do
  use FabionWeb.Graphql

  node object :repository do
    field :gcloud_repo, non_null(:string)
    field :gcloud_project_id, non_null(:string)
    field :github_repo, non_null(:string)
  end

  connection node_type: :repository do
    field :total_count, :integer

    edge do
    end
  end
end
