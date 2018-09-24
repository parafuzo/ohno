defmodule Fabion.Repo.Migrations.CreateBuilderStage do
  use Ecto.Migration

  alias Fabion.Builder.WhenType

  def change do
    when_types = WhenType.__enum_map__

    execute(
      "CREATE TYPE when_type AS ENUM ('#{Enum.join(when_types, "', '")}')",
      "DROP TYPE when_type"
    )

    create table(:builder_stage, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :stage_group, :string
      add :when, :when_type
      add :except, {:array, :string}
      add :only, {:array, :string}
      add :config_file, :string
      add :config, :map
      add :cloudbuild, :map
      add :pipeline_id, references(:builder_pipeline, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:builder_stage, [:pipeline_id])
  end
end
