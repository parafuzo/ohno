defmodule Ohno.Accounts.GithubUser do
  use Ohno, :schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts_github_users" do
    field :node_id, :string
    field :login, :string
    field :avatar_url, :string
    field :html_url, :string

    timestamps()
  end

  @doc false
  def changeset(github_user, attrs) do
    github_user
    |> cast(attrs, [:node_id, :login, :html_url, :avatar_url])
    |> validate_required([:node_id, :login, :html_url, :avatar_url])
  end
end
