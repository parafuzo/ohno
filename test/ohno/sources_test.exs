defmodule Ohno.SourcesTest do
  use Ohno.DataCase, async: true

  import Mox
  alias Ohno.Sources

  test "update status with adapter" do
    Ohno.MockSourcesAdapter
      |> expect(:client, 1, fn -> :client end)
      |> expect(:statuses, 1, fn
        :client, repo, sha, params -> {:ok, ~M{repo, sha, params}}
      end)

    params = %{ state: "success" }
    repo   = "parafuzo/ohno"
    sha    = "commit_sha"
    {:ok, %{params: ^params, repo: ^repo, sha: ^sha}} = Sources.statuses(repo, sha, params)
  end
end
