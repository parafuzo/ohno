defmodule Fabion.Repo.Migrations.CreateBuilderPipeline do
  use Ecto.Migration

  alias Fabion.Builder.PipelineFromType

  def change do
    from_types = PipelineFromType.__enum_map__

    execute(
      "CREATE TYPE pipeline_from_type AS ENUM ('#{Enum.join(from_types, "', '")}')",
      "DROP TYPE pipeline_from_type"
    )

    create table(:builder_pipeline, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :params, :map
      add :errors, :map
      add :from_type, :pipeline_from_type

      add :repository_id, references(:sources_repositories, on_delete: :nothing, type: :binary_id)
      add :sender_id, references(:accounts_github_users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:builder_pipeline, [:repository_id])
    create index(:builder_pipeline, [:sender_id])
  end
end
