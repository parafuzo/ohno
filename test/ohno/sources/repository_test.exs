defmodule Ohno.Sources.RepositoryTest do
  use Ohno.DataCase, async: true

  import Ecto.Changeset

  alias Ohno.Sources.Repository
  alias Ohno.Sources.Repository, as: Schema

  describe to_string(Repository) do
    test "return error for invalid changeset attrs" do
      {:error, %{errors: errors}} =
        Schema.changeset(%{}) |> Repo.insert

      requireds = [:gcloud_repo, :gcloud_project_id, :github_repo, :github_token]
      for field <- requireds do
        assert_validate(:required, field, errors)
      end
    end

    test "make a valid data with factory" do
      resource = params_with_assocs(:repository, %{github_secret: nil})
        |> Schema.changeset()
        |> Repo.insert!

      assert resource.github_secret != nil
      assert Repo.get!(Schema, resource.id) == resource
    end

    test "don't auto upgrade github_secret" do
      resource = params_with_assocs(:repository)
        |> Schema.changeset()
        |> Repo.insert!

      changeset = Schema.changeset(resource, %{})
      assert get_change(changeset, :github_secret) == nil
    end
  end
end
