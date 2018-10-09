defmodule Ohno.Builder.StageTest do
  use Ohno.DataCase, async: true

  alias Ohno.Builder.Pipeline
  alias Ohno.Builder.Stage, as: Schema

  describe to_string(Schema) do
    test "return error for invalid changeset attrs" do
      {:error, %{errors: errors}} = Schema.changeset(%{}) |> Repo.insert()

      requireds = [:pipeline_id, :name, :config_file, :config]

      for field <- requireds do
        assert_validate(:required, field, errors)
      end
    end

    test "make a valid data with factory" do
      resource =
        params_with_assocs(:stage)
        |> Schema.changeset()
        |> Repo.insert!()
        |> Repo.preload([:pipeline])

      assert Repo.get!(Schema, resource.id)
             |> Repo.preload([:pipeline]) == resource

      assert %Pipeline{} = resource.pipeline
      assert [] = resource.only
      assert [] = resource.except
    end
  end
end
