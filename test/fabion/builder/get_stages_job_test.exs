defmodule Fabion.Builder.GetStagesJobTest do
  use Fabion.DataCase, async: true

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
      mock_adapter(pipeline, """
        stages:
          - name: test
            config: ./cloudbuild/test.yaml
          - name: release
            config: ./cloudbuild/release.yaml
      """)

      %{stages: []} = pipeline |> Repo.preload(:stages)
      :ok = Job.perform(pipeline.id)
      %{stages: [%Stage{} = stage | _]} = pipeline |> Repo.preload(:stages)

      assert stage.name == "test"
      assert stage.config_file == "./cloudbuild/test.yaml"
      assert stage.pipeline_id == pipeline.id
    end

    test "valid yaml and save errors in pipeline", ~M{pipeline} do
      mock_adapter(pipeline, """
        stages:
          - name: 1
            when: NOT_VALID
      """)

      :error = Job.perform(pipeline.id)
      %Pipeline{errors: errors} = Repo.get(Pipeline, pipeline.id)
      errors = errors |> Map.to_list()
      assert {"fabion/stages/0", "Required property config was not present."} in errors
      assert {"fabion/stages/0/name", "Type mismatch. Expected String but got Integer."} in errors
      assert {"fabion/stages/0/when", "Value \"NOT_VALID\" is not allowed in enum."} in errors
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
    end
  end
end
