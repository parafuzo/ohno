defmodule Fabion.Sources.Repository do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sources_repositories" do
    field :github, :string
    field :gcloud_repo, :string
    field :secret, :string
    field :token, :string

    timestamps()
  end

  @doc false
  def changeset(attrs = %{}) do
    changeset(%__MODULE__{}, attrs)
  end

  @doc false
  def changeset(repository, attrs) do
    repository
    |> cast(attrs, [:github, :gcloud_repo, :secret, :token])
    |> maybe_generate_secret()
    |> validate_required([:github, :gcloud_repo, :secret, :token])
  end

  def maybe_generate_secret(changeset) do
    case get_field(changeset, :secret) do
      nil ->
        secret = random_string()
        put_change(changeset, :secret, secret)
      _ ->
        changeset
    end
  end

  defp random_string(length \\ 32) when length > 31 do
    length |> :crypto.strong_rand_bytes() |> Base.encode64() |> binary_part(0, length)
  end
end
