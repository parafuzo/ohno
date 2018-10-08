defmodule Fabion.Builder.GetStagesJob do
  import ShorterMaps

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

    with {:ok, manifest} <- get_yaml(pipeline, "./fabion.yaml"),
         :ok <- validate_manifest(manifest),
         {:ok, _} <- make_stages(pipeline, manifest),
         {:ok, _} <- Fabion.Builder.make_jobs(pipeline) do
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

  defp make_stages(%Pipeline{} = pipeline, manifest) do
    Repo.transaction(fn -> make_transation(pipeline, manifest) end)
  catch
    {:error, {:invalid_schema, _}} = error -> error
  end

  defp make_transation(%Pipeline{} = pipeline, ~m{stages} = manifest) do
    Pipeline.changeset(pipeline, %{
      stages_groups: stages,
      manifest: manifest
    })
    |> Repo.update!()

    manifest
    |> Map.delete("stages")
    |> Enum.map(&validate_stage(pipeline, stages, &1))
    |> Enum.map(&Task.async(__MODULE__, :get_config, [&1]))
    |> Enum.map(&Task.await/1)
    |> Enum.map(fn
      {:error, _} = error -> throw(error)
      attrs -> Stage.changeset(attrs)
    end)
    |> Enum.each(&Repo.insert!/1)
  end

  defp validate_stage(pipeline, stages, {name, item}) do
    stage_group = item["stage"] || name
    if not (stage_group in stages) do
      message = "Stage group #{stage_group} is missing in stages."
      errors = %{"fabion/#{name}/stage" => message}
      throw({:error, {:invalid_schema, errors}})
    else
      %{
        pipeline: pipeline,
        pipeline_id: pipeline.id,
        name: name,
        config: item,
        stage_group: stage_group,
        config_file: item["config"]
      }
    end
  end

  def get_config(~M{pipeline, config_file} = stage) do
    case get_yaml(pipeline, config_file) do
      {:ok, cloudbuild} ->
        Map.put(stage, :cloudbuild, cloudbuild)
      {:error, error} ->
        errors = %{"config_file" => "Error to get file #{config_file}: #{error}"}
        {:error, {:invalid_schema, errors}}
    end
  end

  defp get_yaml(pipeline, file) do
    %{ repository: ~M{github_repo} } = pipeline
    commit_sha = Pipeline.get_refs(pipeline)

    case Sources.get_file(github_repo, commit_sha, file) do
      {:ok, content} when is_bitstring(content) ->
        YamlElixir.read_from_string(content)
      {:error, :not_found_file} ->
        {:error, "Not found in repository for #{commit_sha} refs"}
      other -> other
    end
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
