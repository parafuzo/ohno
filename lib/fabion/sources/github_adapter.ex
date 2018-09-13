defmodule Fabion.Sources.GithubAdapter do
  use Tesla

  import ShorterMaps
  @behaviour Fabion.Sources.SourcesAdapter

  @raw_url "https://raw.githubusercontent.com"
  plug(Tesla.Middleware.BaseUrl, "https://api.github.com")
  plug(Tesla.Middleware.JSON, engine: Poison)

  def client() do
    Tesla.build_client([
      {Tesla.Middleware.Headers,
       [
         {"User-Agent", "Fabion"},
         {"Content-Type", "application/json"},
         {"Authorization", "token " <> config(:auth_token)}
       ]}
    ])
  end

  def statuses(client, repo, commit_sha, parameters) do
    client
    |> post("/repos/#{repo}/statuses/#{commit_sha}", parameters)
    |> response
  end

  def get_file(client, repo, ref, path) do
    url =
      [@raw_url, repo, ref, path]
      |> Path.join()

    get(client, url) |> response()
  end

  defp config(key) do
    Keyword.get(configs(), key)
  end

  defp configs do
    Application.get_env(:fabion, Fabion.Sources)
  end

  defp response({:ok, ~M{%Tesla.Env status, body}}) when status in 200..399 do
    {:ok, body}
  end

  defp response({:ok, %Tesla.Env{} = resp}) do
    {:error, resp}
  end

  defp response(error), do: error
end
