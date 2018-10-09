defmodule Ohno.Repo.Migrations.CreateAccountsGithubUser do
  use Ecto.Migration

  def change do
    create table(:accounts_github_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :node_id, :string
      add :login, :string
      add :html_url, :string
      add :avatar_url, :string

      timestamps()
    end

    create index(:accounts_github_users, [:node_id])
  end
end
