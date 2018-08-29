defmodule Fabion.Source.GithubAdapterTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Fabion.Source.GithubAdapter

  describe to_string(__MODULE__) do
    setup do
      ExVCR.Config.filter_request_headers("Authorization")
      :ok
    end

    test "fail to set a state for invalid commit sha" do
      use_cassette "github_404_commit" do
        {:error, %{status_code: 422}} = GithubAdapter.statuses("nuxlli/fabion", "xpto", %{
          state: "sucess"
        })
      end
    end

    @commit_sha "34c4a004a90f3aa4985c9edf374a98a6fc77c7b2"
    test "update a state for valid commit sha" do
      use_cassette "github_statuses_commit" do
        {:ok, %{"state" => "success"}} = GithubAdapter.statuses("nuxlli/fabion", @commit_sha, %{
          state: "success",
          description: "Test github api client in this project",
          context: "fabion/test"
        })
      end
    end
  end
end
