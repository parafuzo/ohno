defmodule Fabion.Source.GithubAdapter do
  import ShorterMaps
  @behaviour Fabion.Source.SourceAdapter

  def statuses(repo, commit_sha, parameters) do
    post_request("/repos/#{repo}/statuses/#{commit_sha}", parameters)
  end

  use HTTPoison.Base

  def process_url(url) do
    "https://api.github.com" <> url
  end

  def process_request_headers(headers) do
    headers ++ [
      {"Content-Type", "application/json"},
      {"Authorization", "token #{config(:auth_token)}"},
    ]
  end

  def process_status_code(status) when status >= 200 and status < 300, do: 200
  def process_status_code(status), do: status

  # @fields [:api_id, :message, :message_uuid, :invalid_number, :error]
  def process_response_body(body) do
    body
      |> Poison.decode!()
      # |> Map.take(@fields)
  end

  defp config(key) do
    Keyword.get(configs(), key)
  end

  defp configs do
    Application.get_env(:fabion, Fabion.Source)
  end

  defp post_request(path, body, status \\ 200) do
    with \
      {:ok, body} <- Poison.encode(body),
      {:ok, ~M{%HTTPoison.Response status_code: ^status, body}} <- post(path, body)
    do
      case body do
        %{error: _} -> {:error, {:integrator, body}}
        _ -> {:ok, body}
      end
    else
      {:ok, %HTTPoison.Response{} = error} -> {:error, error}
      {:error, %HTTPoison.Error{} = error} -> {:error, error}
      error -> error
    end
  end
end
