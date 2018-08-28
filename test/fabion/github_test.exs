defmodule Fabion.GithubTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Fabion.Github

  describe to_string(__MODULE__) do
    setup do
      ExVCR.Config.filter_request_headers("Authorization")
      :ok
    end

    test "fail to set a state for invalid commit sha" do
      use_cassette "github_404_commit" do
        {:error, %{status_code: 404}} = Github.statuses("nuxlli/fabion", "xpto", %{
          state: "sucess"
        })
      end
    end
  end
end
