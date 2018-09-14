defmodule Fabion.Repo.Migrations.CreateSourcesRepositoryEvents do
  use Ecto.Migration

  alias Fabion.Sources.RepositoryEventType

  def change do
    event_type = RepositoryEventType.__enum_map__

    execute(
      "CREATE TYPE repository_event_type AS ENUM ('#{Enum.join(event_type, "', '")}')",
      "DROP TYPE repository_event_type"
    )

    create table(:sources_repository_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :params, :map
      add :repository_id, references(:sources_repositories, on_delete: :nothing, type: :binary_id)
      add :sender_id, references(:accounts_github_users, on_delete: :nothing, type: :binary_id)

      add :type, :repository_event_type

      timestamps()
    end

    create index(:sources_repository_events, [:repository_id])
    create index(:sources_repository_events, [:sender_id])
  end
end
