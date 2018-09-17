defmodule Fabion.BuilderTest do
  use Fabion.DataCase, async: true

  alias Fabion.Builder
  import GenQueue.Test
  alias Fabion.Enqueuer
  alias Fabion.Builder.GetStagesJob

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

    test "make a pipeline from a push_event and params", ~M{repo, push_params} do
      {:ok, pipeline} = Builder.add_pipeline("push", push_params)

      pipeline = pipeline |> Repo.preload(:sender)

      assert pipeline.repository_id == repo.id
      assert pipeline.sender_id != nil
      assert pipeline.sender.node_id == jq!(push_params, ".sender.node_id")
      assert pipeline.from_type == :PUSH_EVENT
      assert pipeline.params == push_params
    end

    test "enquee pipeline to make stages", ~M{push_params}  do
      {:ok, %{id: id}} = Builder.add_pipeline("push", push_params)
      assert_receive(%GenQueue.Job{module: GetStagesJob, args: [^id]})
    end
  end
end
