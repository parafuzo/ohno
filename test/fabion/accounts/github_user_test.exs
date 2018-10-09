defmodule Fabion.Accounts.GithubUserTest do
  use Fabion.DataCase, async: true

  alias Fabion.Accounts.GithubUser, as: Schema

  describe to_string(Schema) do
    test "return error for invalid changeset attrs" do
      {:error, %{errors: errors}} =
        Schema.changeset(%{}) |> Repo.insert

      requireds = [:node_id, :login, :html_url, :avatar_url]
      for field <- requireds do
        assert_validate(:required, field, errors)
      end
    end

    test "make a valid data with factory" do
      resource = params_with_assocs(:github_user, %{})
        |> Schema.changeset()
        |> Repo.insert!

      assert Repo.get!(Schema, resource.id) == resource
    end
  end
end
