defmodule Fabion.SourcesTest do
  use Fabion.DataCase, async: true

  import Mox
  alias Fabion.Sources

  import GenQueue.Test
  alias Fabion.Enqueuer
  alias Fabion.Sources.ProcessEventJob

  test "update status with adapter" do
    Fabion.MockSourcesAdapter
      |> expect(:client, 1, fn -> :client end)
      |> expect(:statuses, 1, fn
        :client, repo, sha, params -> {:ok, ~M{repo, sha, params}}
      end)

    params = %{ state: "success" }
    repo   = "nuxlli/fabion"
    sha    = "commit_sha"
    {:ok, %{params: ^params, repo: ^repo, sha: ^sha}} = Sources.statuses(repo, sha, params)
  end

  describe "there is a repository in the database" do
    setup do
      setup_test_queue(Enqueuer)

      {:ok, ~M{github_repo} = repo} =
        params_with_assocs(:repository)
        |> Fabion.Sources.add_repository()

      url = "https://github.com/#{github_repo}"
      push_params =
        read_file_event!("push_commit")
        |> Map.update!("repository", &Map.put(&1, "url", url))

      ~M{repo, push_params}
    end

    test "make a push event from a params", ~M{repo, push_params} do
      {:ok, event} = Sources.add_event("push", push_params)

      event = event |> Repo.preload(:sender)

      assert event.repository_id == repo.id
      assert event.sender_id != nil
      assert event.sender.node_id == jq!(push_params, ".sender.node_id")
      assert event.type == :PUSH
      assert event.params == push_params
    end

    test "enquee event to process", ~M{push_params}  do
      {:ok, %{id: id}} = Sources.add_event("push", push_params)
      assert_receive(%GenQueue.Job{module: ProcessEventJob, args: [^id]})
    end
  end
end
