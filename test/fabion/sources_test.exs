defmodule Fabion.SourcesTest do
  use ExUnit.Case, async: true

  import Mox
  import ShorterMaps

  alias Fabion.Sources

  describe to_string(__MODULE__) do
    test "update status with adapter" do
      Fabion.MockSourcesAdapter
        |> expect(:statuses, 1, fn
          repo, sha, params -> {:ok, ~M{repo, sha, params}}
        end)

      params = %{ state: "success" }
      repo   = "nuxlli/fabion"
      sha    = "commit_sha"
      {:ok, %{params: ^params, repo: ^repo, sha: ^sha}} = Sources.statuses(repo, sha, params)
    end
  end
end
