defmodule Fabion.Builder.Pipeline do
  use Fabion, :schema

  alias Fabion.Builder.PipelineFromType

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "builder_pipeline" do
    field(:from_type, PipelineFromType)
    field(:params, :map)
    field(:stages_groups, {:array, :string}, default: [])
    field(:manifest, :map, default: nil)
    field(:stages_errors, :map, default: nil)

    belongs_to(:repository, Fabion.Sources.Repository)
    belongs_to(:sender, Fabion.Accounts.GithubUser)

    has_many(:stages, Fabion.Builder.Stage)

    timestamps()
  end

  @required_fields [:params, :from_type, :repository_id, :sender_id]
  @optional_fields [:stages_groups, :manifest, :stages_errors]

  @doc false
  def changeset(pipeline, attrs) do
    pipeline
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:from_type, PipelineFromType.__enum_map__())
    |> validate_params()
  end

  defp validate_params(changeset) do
    validate_params(changeset, get_field(changeset, :from_type))
  end

  @push_schema load_schema(:push)
  defp validate_params(changeset, :PUSH_EVENT) do
    params = get_field(changeset, :params)

    case ExJsonSchema.Validator.validate(@push_schema, params) do
      :ok ->
        changeset

      {:error, errors} ->
        add_json_errors(changeset, :params, errors)
    end
  end

  defp validate_params(changeset, _) do
    changeset
  end
end
