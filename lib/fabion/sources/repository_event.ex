defmodule Fabion.Sources.RepositoryEvent do
  use Fabion, :schema

  alias Fabion.Sources.RepositoryEventType

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sources_repository_events" do
    field :params, :map
    field :type, RepositoryEventType

    belongs_to(:repository, Fabion.Sources.Repository)
    belongs_to(:sender, Fabion.Accounts.GithubUser)

    timestamps()
  end

  @required_fields [:params, :type, :repository_id, :sender_id]
  @optional_fields []

  @doc false
  def changeset(repository_event, attrs) do
    repository_event
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, RepositoryEventType.__enum_map__)
    |> validate_params()
  end

  defp validate_params(changeset) do
    case get_field(changeset, :type) do
      :PUSH -> validate_push(changeset)
      _ -> changeset
    end
  end

  @push_schema load_schema(:push)
  defp validate_push(changeset) do
    params = get_field(changeset, :params)
    case ExJsonSchema.Validator.validate(@push_schema, params) do
      :ok -> changeset
      {:error, errors} ->
        add_json_errors(changeset, :params, errors)
    end
  end
end
