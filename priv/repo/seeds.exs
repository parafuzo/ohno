# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Fabion.Repo.insert!(%Fabion.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Fabion.Repo

defmodule Fabion.Seeds do
  def add(module, %{id: id} = attrs) do
    case Repo.get(module, id) do
      %{__struct__: ^module} = r -> r
      _ -> struct(module, id: id)
    end
    |> module.changeset(Map.delete(attrs, :id))
    |> Repo.insert_or_update()
  end

  def json_data!(data) do
    file = Path.join([__DIR__, "seeds/data/#{data}.json"])
    case File.exists?(file) do
      true ->
        File.read!(file) |> Poison.Parser.parse!(%{keys: :atoms})
      false ->
        nil
    end
  end
end

Code.eval_file("seeds/repositories_seed.exs", __DIR__)
