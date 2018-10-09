defmodule Fabion.Builder.GetStagesJobTest do
  use Fabion.DataCase, async: false

  import Indifferent.Sigils
  # require Indifferent

  import Mox

  import GenQueue.Test
  alias Fabion.Enqueuer
  alias Fabion.Builder.ProcessJob

  alias Fabion.Builder.{Pipeline, Stage}
  alias Fabion.Builder.GetStagesJob, as: Job

  describe "extract stages from pipeline" do
    setup :set_mox_from_context

    setup do
      pipeline = pipeline_with_params(:PUSH_EVENT, "push_commit")
      ~M{pipeline}
    end

    @good_case %{
      "./fabion.yaml" => """
        stages:
          - test
          - release

        test:
          config: ./cloudbuild/test.yaml

        release:
          stage: release
          config: ./cloudbuild/release.yaml
      """,
      "./cloudbuild/test.yaml" => """
        steps:
          - name: gcr.io/cloud-builders/gcloud
            entrypoint: /bin/bash
            args: ['-c', 'echo "test stage"']
      """,
      "./cloudbuild/release.yaml" => """
        steps:
          - name: gcr.io/cloud-builders/gcloud
            entrypoint: /bin/bash
            args: ['-c', 'echo "release stage"']
      """
    }

    test "get fabion.yaml from repo and create stages", ~M{pipeline} do
      {:ok, %{"./fabion.yaml" => manifest}} = mock_adapter(pipeline, @good_case)

      %{stages: []} = pipeline |> Repo.preload(:stages)
      :ok = Job.perform(pipeline.id)

      pipeline = Repo.get(Pipeline, pipeline.id) |> Repo.preload(:stages)

      groups = manifest |> ~i(stages)

      assert %Pipeline{
               stages_groups: ^groups,
               manifest: ^manifest
             } = pipeline

      manifest_stages = manifest |> Map.drop(["stages"]) |> Enum.to_list()
      assert length(manifest_stages) == length(pipeline.stages)

      for {name, item} <- manifest_stages do
        stage = Repo.get_by(Stage, name: name, pipeline_id: pipeline.id)

        assert not is_nil(stage)
        assert stage.stage_group == item["stage"] || name
        assert stage.config_file == item["config"]
      end
    end

    test "get stages config files and save in stage", ~M{pipeline} do
      {:ok,
       %{
         "./cloudbuild/test.yaml" => test_config
       }} = mock_adapter(pipeline, @good_case)

      :ok = Job.perform(pipeline.id)
      %{stages: [stage | _]} = Repo.get(Pipeline, pipeline.id) |> Repo.preload(:stages)

      assert stage.name == "test"
      assert stage.cloudbuild == test_config
    end

    test "make job for stage after create stages", ~M{pipeline} do
      :ok = setup_test_queue(Enqueuer)
      {:ok, %{}} = mock_adapter(pipeline, @good_case)

      :ok = Job.perform(pipeline.id)
      %{stages: [stage | _]} = Repo.get(Pipeline, pipeline.id) |> Repo.preload(stages: [:jobs])

      %Stage{jobs: [%Fabion.Builder.Job{id: job_id}]} = stage
      assert_receive(%GenQueue.Job{module: ProcessJob, args: [%{id: ^job_id}]})
    end

    test "valid yaml and save errors in pipeline", ~M{pipeline} do
      mock_adapter(pipeline, """
        test:
          stage: 1
          invalid_key: hello
      """)

      :error = Job.perform(pipeline.id)

      %Pipeline{stages_errors: errors, stages: []} =
        Repo.get(Pipeline, pipeline.id) |> Repo.preload(:stages)

      errors = errors |> Map.to_list()
      assert {"fabion", "Required property stages was not present."} in errors
      assert {"fabion/test", "Required property config was not present."} in errors
      assert {"fabion/test/invalid_key", "Schema does not allow additional properties."} in errors
      assert {"fabion/test/stage", "Type mismatch. Expected String but got Integer."} in errors
    end

    test "return error if not found config file", ~M{pipeline} do
      config_file = "./cloudbuild/test.yaml"
      refs = Pipeline.get_refs(pipeline)

      mock_adapter(pipeline, """
        stages:
          - test

        test:
          config: #{config_file}
      """)

      :error = Job.perform(pipeline.id)

      %Pipeline{stages_errors: errors, stages: []} =
        Repo.get(Pipeline, pipeline.id) |> Repo.preload(:stages)

      errors = errors |> Map.to_list()

      message = "Error to get file #{config_file}: Not found in repository for #{refs} refs"
      assert {"config_file", message} in errors
    end

    test "validate stages groups before create stage", ~M{pipeline} do
      mock_adapter(pipeline, """
        stages:
          - test

        test:
          config: ./cloudbuild/test.yaml

        release:
          stage: release
          config: ./cloudbuild/release.yaml
      """)

      :error = Job.perform(pipeline.id)

      %Pipeline{stages_errors: errors, stages: []} =
        Repo.get(Pipeline, pipeline.id) |> Repo.preload(:stages)

      errors = errors |> Map.to_list()

      assert {"fabion/release/stage", "Stage group release is missing in stages."} in errors
    end

    def mock_adapter(pipeline, content) when is_bitstring(content) do
      mock_adapter(pipeline, %{"./fabion.yaml" => content})
    end

    def mock_adapter(pipeline, %{} = files) do
      %{repository: ~M{github_repo}, params: params} = pipeline
      sha = jq!(params, ".head_commit.id")

      Fabion.MockSourcesAdapter
      |> stub(:client, fn -> :client end)
      |> stub(:get_file, fn :client, ^github_repo, ^sha, path ->
        case Map.get(files, path) do
          nil -> {:error, :not_found_file}
          content -> {:ok, content}
        end
      end)

      yamls = files |> Enum.map(&yaml_to_map/1) |> Map.new()
      {:ok, yamls}
    end

    def yaml_to_map({path, content}) do
      {:ok, yaml} = YamlElixir.read_from_string(content)
      {path, yaml}
    end
  end
end
