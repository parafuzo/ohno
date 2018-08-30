defmodule FabionWeb.Graphql.Sources.Types do
  use FabionWeb.Graphql

  node object :repository do
    field :github, non_null(:string)
    field :gcloud_repo, non_null(:string)
    field :secret, non_null(:string)
    field :token, non_null(:string)
  end

  connection node_type: :repository do
    field :total_count, :integer

    edge do
    end
  end
end
