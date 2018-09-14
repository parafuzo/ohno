defmodule Fabion.Sources.RepositoryEventTest do
  use Fabion.DataCase, async: true

  alias Fabion.Accounts.GithubUser
  alias Fabion.Sources.Repository
  alias Fabion.Sources.RepositoryEvent, as: Schema

  describe to_string(Schema) do
    test "return error for invalid changeset attrs" do
      {:error, %{errors: errors}} = Schema.changeset(%{}) |> Repo.insert()

      requireds = [:params, :type, :repository_id, :sender_id]

      for field <- requireds do
        assert_validate(:required, field, errors)
      end
    end

    test "make a valid data with factory" do
      resource =
        params_with_assocs(:repository_event, %{type: :PULL_REQUEST})
        |> Schema.changeset()
        |> Repo.insert!()
        |> Repo.preload([:repository, :sender])

      assert Repo.get!(Schema, resource.id)
             |> Repo.preload([:repository, :sender]) == resource

      assert %Repository{} = resource.repository
      assert %GithubUser{} = resource.sender
    end

    test "return error for invalidate params in push event" do
      {:error, %{errors: errors, valid?: false}} =
        params_with_assocs(:repository_event, %{type: :PUSH, params: %{}})
        |> Schema.changeset()
        |> Repo.insert()

      assert {:params, {"/: Required property sender was not present.", []}} in errors
      assert {:params, {"/: Required property repository was not present.", []}} in errors
      assert {:params, {"/: Required property ref was not present.", []}} in errors
      assert {:params, {"/: Required property head_commit was not present.", []}} in errors
    end

    test "insert a push event if is valid" do
      params = read_file_event!("push_commit")

      {:ok, %Schema{params: ^params}} =
        params_with_assocs(:repository_event, %{type: :PUSH, params: params})
        |> Schema.changeset()
        |> Repo.insert()

      {:error, %{errors: errors, valid?: false}} =
        params
        |> Map.update!("repository", &Map.put(&1, "url", nil))
        ~> Map.put(%{type: :PUSH}, :params, _)
        ~> params_with_assocs(:repository_event, _)
        |> Schema.changeset()
        |> Repo.insert()

      assert {:params, {"/repository/url: Type mismatch. Expected String but got Null.", []}} in errors
    end
  end
end
