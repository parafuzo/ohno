defmodule Fabion.Builder.GetStagesJob do
  import ShorterMaps
  import PipeTo

  import Fabion.BaseSchema,
    only: [
      load_schema: 1,
      errors_to_map: 2
    ]

  alias Ecto.Multi
  alias ExJsonSchema.Validator

  alias Fabion.Repo
  alias Fabion.Sources
  alias Fabion.Builder.Pipeline
  alias Fabion.Builder.Stage

  def perform(pipeline_id) do
    {:ok, pipeline} = get_pipeline(pipeline_id)

    %{
      repository: ~M{github_repo},
      params: %{
        "head_commit" => %{
          "id" => commit_sha
        }
      }
    } = pipeline

    with {:ok, content} <- Sources.get_file(github_repo, commit_sha, "./fabion.yaml"),
         {:ok, config} <- YamlElixir.read_from_string(content),
         :ok <- valid_config(config),
         {:ok, _} <- make_stages(pipeline, config) do
      :ok
    else
      {:error, {:invalid_schema, errors}} ->
        Pipeline.changeset(pipeline, ~M{errors})
        |> Repo.update!
        :error
      other -> other
    end
  end

  # TODO: save the execution order
  # maybe with: https://github.com/coryodaniel/arbor
  defp make_stages(%{id: pipeline_id}, ~m{stages}) do
    stages
    |> Enum.with_index()
    |> Enum.reduce(Multi.new(), fn
      {~m{name, config} = stage, index}, multi ->
        ~M{pipeline_id, name, config: stage, config_file: config}
        |> Stage.changeset()
        ~> Multi.insert(Multi.new(), index, _)
        |> Multi.append(multi)
    end)
    |> Repo.transaction()
  end

  @fabion_schema load_schema(:fabion)

  defp valid_config(config) do
    with {:error, errors} <- Validator.validate(@fabion_schema, config) do
      {:error, {:invalid_schema, errors_to_map("fabion", errors)}}
    end
  end

  defp get_pipeline(id) do
    case Repo.get(Pipeline, id) do
      %Pipeline{} = r -> {:ok, r |> Repo.preload(:repository)}
      _ -> {:error, :not_found}
    end
  end
end
