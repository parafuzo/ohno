defmodule Ohno.Repo.Migrations.CreateSourcesRepositories do
  use Ecto.Migration

  def change do
    create table(:sources_repositories, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(:github_repo, :string)
      add(:gcloud_project_id, :string)
      add(:github_secret, :string)
      add(:gcloud_repo, :string)
      add(:github_token, :string)

      timestamps()
    end

    create index(:sources_repositories, [:github_repo])
  end
end
