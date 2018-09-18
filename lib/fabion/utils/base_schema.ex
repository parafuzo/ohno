defmodule Fabion.BaseSchema do
  import Ecto.Changeset

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import unquote(__MODULE__)

      import ShorterMaps
      import PipeTo

      @doc false
      def changeset(attrs = %{}) do
        changeset(struct!(__MODULE__, []), attrs)
      end
    end
  end

  def load_schema(name) do
    ["#{:code.priv_dir(:fabion)}", "schemas", "#{name}.json"]
    |> Path.join()
    |> File.read!()
    |> Poison.decode!()
  end

  def random_string(length \\ 32) when length > 31 do
    :crypto.strong_rand_bytes(length)
    |> Base.encode64()
    |> binary_part(0, length)
  end

  def add_json_errors(changeset, root, errors) do
    Enum.reduce(errors, changeset, fn
      {message, "#"}, changeset ->
        add_error(changeset, root, "/: #{message}")

      {message, <<"#", path::binary>>}, changeset ->
        add_error(changeset, root, "#{path}: #{message}")
    end)
  end

  def errors_to_map(root, errors) do
    Enum.reduce(errors, %{}, fn
      {message, "#"}, acc ->
        Map.put(acc, root, message)

      {message, <<"#", path::binary>>}, acc ->
        Map.put(acc, Path.join([root, path]), message)
    end)
  end
end
