defmodule Fabion.Builder.GetStagesJobTest do
  use Fabion.DataCase, async: true

  import Mox
  alias Fabion.Builder.GetStagesJob, as: Job

  describe to_string(__MODULE__) do
    setup do
      pipeline = pipeline_with_params(:PUSH_EVENT, "push_commit")
      %{repository: ~M{github_repo}, params: params} = pipeline
      sha = jq!(params, ".head_commit.id")

      # IO.inspect(~M{sha, github_repo})

      Fabion.MockSourcesAdapter
      |> expect(:client, 1, fn -> :client end)
      |> expect(:get_file, 1, fn
        :client, ^github_repo, ^sha, "./fabion.yaml" ->
          {:ok,
           """
            stages:
              - name: test
                config: cloudbuild/test.yaml
           """}
      end)

      ~M{pipeline}
    end

    test "job gets fabion.yaml from repo", ~M{pipeline} do
      :ok = Job.perform(pipeline.id)
      # pipeline |> IO.inspect()
      verify!()
    end
  end
end
