defmodule Fabion.Sources.Repository do
  use Fabion, :schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sources_repositories" do
    field :gcloud_repo, :string
    field :github_repo, :string
    field :github_secret, :string
    field :github_token, :string

    has_many(:pipelines, Fabion.Builder.Pipeline)

    timestamps()
  end

  @doc false
  def changeset(repository, attrs) do
    repository
    |> cast(attrs, [:github_repo, :gcloud_repo, :github_secret, :github_token])
    |> maybe_generate_secret()
    |> validate_required([:github_repo, :gcloud_repo, :github_secret, :github_token])
  end

  def maybe_generate_secret(changeset) do
    case get_field(changeset, :github_secret) do
      nil ->
        github_secret = random_string()
        put_change(changeset, :github_secret, github_secret)
      _ ->
        changeset
    end
  end
end
