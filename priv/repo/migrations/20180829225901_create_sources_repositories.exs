defmodule Fabion.Repo.Migrations.CreateSourcesRepositories do
  use Ecto.Migration

  def change do
    create table(:sources_repositories, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(:github, :string)
      add(:gcloud_repo, :string)
      add(:secret, :string)
      add(:token, :string)

      timestamps()
    end
  end
end
