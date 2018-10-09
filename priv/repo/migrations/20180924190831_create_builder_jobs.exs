defmodule Ohno.Repo.Migrations.CreateBuilderJobs do
  use Ecto.Migration

  alias Ohno.Builder.JobStatus

  def change do
    job_status = JobStatus.__enum_map__

    execute(
      "CREATE TYPE job_status AS ENUM ('#{Enum.join(job_status, "', '")}')",
      "DROP TYPE job_status"
    )

    create table(:builder_jobs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :job_status
      add :gcloud_build_id, :binary_id
      add :stage_id, references(:builder_stages, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:builder_jobs, [:stage_id])
  end
end
