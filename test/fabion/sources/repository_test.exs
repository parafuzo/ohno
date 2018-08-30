defmodule Fabion.Sources.RepositoryTest do
  use Fabion.DataCase, async: true

  import Ecto.Changeset

  alias Fabion.Sources.Repository
  alias Fabion.Sources.Repository, as: Schema

  describe to_string(Repository) do
    test "return error for invalid changeset attrs" do
      {:error, %{errors: errors}} =
        Schema.changeset(%{}) |> Repo.insert

      requireds = [:github, :gcloud_repo, :token]
      for field <- requireds do
        assert_validate(:required, field, errors)
      end
    end

    test "make a valid data with factory" do
      resource = params_with_assocs(:repository, %{secret: nil})
        |> Schema.changeset()
        |> Repo.insert!

      assert resource.secret != nil
      assert Repo.get!(Schema, resource.id) == resource
    end

    test "don't auto upgrade secret" do
      resource = params_with_assocs(:repository)
        |> Schema.changeset()
        |> Repo.insert!

      changeset = Schema.changeset(resource, %{})
      assert get_change(changeset, :secret) == nil
    end
  end
end
