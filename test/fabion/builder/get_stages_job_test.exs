defmodule Fabion.Builder.GetStagesJobTest do
  use Fabion.DataCase, async: true

  import Indifferent.Sigils
  # require Indifferent

  import Mox

  alias Fabion.Builder.{Pipeline, Stage}
  alias Fabion.Builder.GetStagesJob, as: Job

  describe "extract stages from pipeline" do
    setup do
      pipeline = pipeline_with_params(:PUSH_EVENT, "push_commit")
      ~M{pipeline}
    end

    setup :verify_on_exit!

    test "get fabion.yaml from repo and create stages", ~M{pipeline} do
      {:ok, manifest} =
        mock_adapter(pipeline, """
          stages:
            - test
            - release

          test:
            stage: test
            config: ./cloudbuild/test.yaml

          release:
            stage: release
            config: ./cloudbuild/release.yaml
        """)


      %{stages: []} = pipeline |> Repo.preload(:stages)
      :ok = Job.perform(pipeline.id)

      pipeline = Repo.get(Pipeline, pipeline.id) |> Repo.preload(:stages)

      groups = manifest |> ~i(stages)
      assert %Pipeline{
               stages_groups: ^groups,
               manifest: ^manifest
             } = pipeline

      manifest_stages = get_in(manifest, [&stages/3]) |> Enum.to_list()
      assert length(manifest_stages) == length(pipeline.stages)

      for {name, item} <- manifest_stages do
        stage = Repo.get_by(Stage, name: name, pipeline_id: pipeline.id)

        assert not is_nil(stage)
        assert stage.stage_group == item["stage"]
        assert stage.config_file == item["config"]
      end
    end

    test "valid yaml and save errors in pipeline", ~M{pipeline} do
      mock_adapter(pipeline, """
        test:
          stage: 1
          invalid_key: hello
      """)

      :error = Job.perform(pipeline.id)
      %Pipeline{stages_errors: errors} = Repo.get(Pipeline, pipeline.id)
      errors = errors |> Map.to_list()
      assert {"fabion", "Required property stages was not present."} in errors
      assert {"fabion/test", "Required property config was not present."} in errors
      assert {"fabion/test/invalid_key", "Schema does not allow additional properties."} in errors
      assert {"fabion/test/stage", "Type mismatch. Expected String but got Integer."} in errors
    end

    def stages(:get, data, next) do
      data
      |> Enum.filter(fn
        {_, %{"stage" => _}} -> true
        _ -> false
      end)
      |> Map.new()
      |> next.()
    end

    def mock_adapter(pipeline, content) do
      %{repository: ~M{github_repo}, params: params} = pipeline
      sha = jq!(params, ".head_commit.id")

      Fabion.MockSourcesAdapter
      |> expect(:client, 1, fn -> :client end)
      |> expect(:get_file, 1, fn
        :client, ^github_repo, ^sha, "./fabion.yaml" ->
          {:ok, content}
      end)

      YamlElixir.read_from_string(content)
    end
  end
end
