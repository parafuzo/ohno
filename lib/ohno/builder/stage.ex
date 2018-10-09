defmodule Ohno.Builder.Stage do
  use Ohno, :schema

  alias Ohno.Builder.WhenType
  alias Ohno.Builder.Job

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "builder_stages" do
    field(:name, :string)
    field(:stage_group, :string)
    field(:when, WhenType, default: :AUTO)
    field(:except, {:array, :string}, default: [])
    field(:only, {:array, :string}, default: [])
    field(:config_file, :string)
    field(:config, :map)
    field(:cloudbuild, :map, default: %{})

    belongs_to(:pipeline, Ohno.Builder.Pipeline)
    has_many(:jobs, Job)

    timestamps()
  end

  def success?(%__MODULE__{jobs: []}), do: false

  def success?(%__MODULE__{jobs: jobs}) when jobs != [] do
    jobs |> List.last() |> Job.success?()
  end

  @required_fields [:pipeline_id, :name, :stage_group, :config_file, :config]
  @optional_fields [:when, :except, :only, :cloudbuild]

  @doc false
  def changeset(stage, attrs) do
    stage
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:when, WhenType.__enum_map__())
  end
end
