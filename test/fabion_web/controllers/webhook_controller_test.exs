defmodule FabionWeb.WebhookControllerTest do
  use FabionWeb.ConnCase

  alias Fabion.Repo

  describe "POST /webhook" do
    setup do
      {:ok, ~M{github_repo} = repo} =
        params_with_assocs(:repository)
        |> Fabion.Sources.add_repository()

      url = "https://github.com/#{github_repo}"

      push_commit =
        read_file_event!("push_commit")
        |> Map.update!("repository", &Map.put(&1, "url", url))

      ~M{repo, push_commit}
    end

    test "a ping event", ~M{conn} do
      response = post_event(conn, "ping") |> json_response(200)

      assert match?(
               %{
                 "messages" => [],
                 "result" => "pong ;)",
                 "successful" => true
               },
               response
             )
    end

    test "an unsupported event", ~M{conn} do
      response = post_event(conn, "any_event") |> json_response(400)

      assert match?(
               %{
                 "messages" => [
                   %{
                     "message" => "Unsupported event type: any_event"
                   }
                 ],
                 "result" => nil,
                 "successful" => false
               },
               response
             )
    end

    test "a push event, create a event", ~M{conn, push_commit, repo} do
      repo_id = repo.id

      response =
        push_commit
        |> Poison.encode!()
        ~> post_event(conn, "push", _)
        |> json_response(200)

      assert match?(
               %{
                 "messages" => [],
                 "successful" => true
               },
               response
             )

      %{events: [event]} = repo |> Repo.preload(:events)

      assert event.id == jq!(response, ".result.id")
      assert event.type == :PUSH
      assert event.repository_id == repo_id
    end

    test "a push event with invalid params return error", ~M{conn, push_commit} do
      response =
        push_commit
        |> Map.delete("ref")
        |> Map.update!("head_commit", &Map.delete(&1, "id"))
        ~> post_event(conn, "push", _)
        |> json_response(400)

      assert match?(
               %{
                 "messages" => [
                   %{
                     "field" => "params",
                     "message" => "/: Required property ref was not present."
                   },
                   %{
                     "field" => "params",
                     "message" => "/head_commit: Required property id was not present."
                   }
                 ],
                 "result" => nil,
                 "successful" => false
               },
               response
             )
    end

    test "a push event, return error for a not registered repo", ~M{conn, push_commit} do
      repo_urls = [
        "https://github.com/github/not_valid_repo",
        "https://example.com/github/not_valid_repo"
      ]

      for url <- repo_urls do
        message = "#{url} repository not registered in the service"

        response =
          push_commit
          |> Map.update!("repository", &Map.put(&1, "url", url))
          |> Poison.encode!()
          ~> post_event(conn, "push", _)
          |> json_response(400)

        assert match?(
                 %{
                   "messages" => [%{"message" => ^message}],
                   "result" => nil,
                   "successful" => false
                 },
                 response
               )
      end
    end
  end

  defp post_event(conn, event, body \\ "{}") do
    conn
    |> put_req_header("x-github-event", event)
    |> put_req_header("content-type", "application/json")
    |> post("/webhook", body)
  end
end
