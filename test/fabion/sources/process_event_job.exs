defmodule Fabion.Sources.ProcessEventJobTest do
  use Fabion.DataCase, async: true

  import Mox
  alias Fabion.Sources.ProcessEventJob, as: Job

  describe to_string(__MODULE__) do
    setup do
      event = repository_event_with_params(:PUSH, "push_commit")
      %{repository: ~M{github_repo}, params: params} = event
      sha = jq!(params, ".head_commit.id")

      IO.inspect(~M{sha, github_repo})

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

      ~M{event}
    end

    test "job gets fabion.yaml from repo", ~M{event} do
      :ok = Job.perform(event.id)
      # event |> IO.inspect()
      verify!()
    end
  end
end
