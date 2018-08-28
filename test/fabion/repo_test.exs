defmodule Fabion.RepoTest do
  use ExUnit.Case, async: true

  import Mox
  import ShorterMaps

  alias Fabion.Repo

  describe to_string(__MODULE__) do
    test "update status with adapter" do
      Fabion.MockRepoAdapter
        |> expect(:statuses, 1, fn
          repo, sha, params -> {:ok, ~M{repo, sha, params}}
        end)

      params = %{ state: "success" }
      repo   = "nuxlli/fabion"
      sha    = "commit_sha"
      {:ok, %{params: ^params, repo: ^repo, sha: ^sha}} = Repo.statuses(repo, sha, params)
    end
  end
end
