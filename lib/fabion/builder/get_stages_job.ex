defmodule Fabion.Builder.GetStagesJob do
  import ShorterMaps
  import PipeTo

  import Fabion.BaseSchema,
    only: [
      load_schema: 1,
      errors_to_map: 2
    ]

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
         {:ok, manifest} <- YamlElixir.read_from_string(content),
          :ok <- validate_manifest(manifest),
         {:ok, _} <- make_stages(pipeline, manifest) do
      :ok
    else
      {:error, {:invalid_schema, stages_errors}} ->
        Pipeline.changeset(pipeline, ~M{stages_errors})
        |> Repo.update!()
        :error
      other ->
        other
    end
  end

  defp make_stages(%Pipeline{} = pipeline, ~m{stages} = manifest) do
    Repo.transaction(fn ->
      Pipeline.changeset(pipeline, %{
        stages_groups: stages,
        manifest: manifest,
      })
      |> Repo.update!()

      manifest =
        manifest
        |> Map.delete("stages")
        |> Enum.to_list()

      for {name, item} <- manifest do
        Stage.changeset(%{
          pipeline_id: pipeline.id,
          name: name,
          config: item,
          stage_group: item["stage"],
          config_file: item["config"],
        })
        |> Repo.insert!()
      end
    end)
  end

  @fabion_schema load_schema(:fabion)
  defp validate_manifest(manifest) do
    with {:error, errors} <- Validator.validate(@fabion_schema, manifest) do
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
