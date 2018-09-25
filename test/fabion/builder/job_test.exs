defmodule Fabion.Builder.JobTest do
  use Fabion.DataCase, async: true

  alias Fabion.Builder.Stage
  alias Fabion.Builder.Job, as: Schema

  describe to_string(Schema) do
    test "return error for invalid changeset attrs" do
      {:error, %{errors: errors}} = Schema.changeset(%{
        status: nil
      }) |> Repo.insert()

      requireds = [:stage_id, :status]

      for field <- requireds do
        assert_validate(:required, field, errors)
      end
    end

    test "make a valid data with factory" do
      resource =
        params_with_assocs(:job)
        |> Schema.changeset()
        |> Repo.insert!()
        |> Repo.preload([:stage])

      assert Repo.get!(Schema, resource.id)
             |> Repo.preload([:stage]) == resource

      assert %Stage{} = resource.stage
      assert :NEW = resource.status
    end
  end
end
