defmodule Fabion.Builder.Stage do
  use Fabion, :schema

  alias Fabion.Builder.WhenType

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "builder_stage" do
    field(:name, :string)
    field(:stage_group, :string)
    field(:when, WhenType, default: :AUTO)
    field(:except, {:array, :string}, default: [])
    field(:only, {:array, :string}, default: [])
    field(:config_file, :string)
    field(:config, :map)
    field(:cloudbuild_extras, :map, default: %{})

    belongs_to(:pipeline, Fabion.Builder.Pipeline)

    timestamps()
  end

  @required_fields [:pipeline_id, :name, :stage_group, :config_file, :config]
  @optional_fields [:when, :except, :only, :cloudbuild_extras]

  @doc false
  def changeset(stage, attrs) do
    stage
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:when, WhenType.__enum_map__())
  end
end
