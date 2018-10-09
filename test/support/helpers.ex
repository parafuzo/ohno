defmodule Ohno.Support.Helpers do
  alias Ohno.Repo

  def read_priv_file!(folder, file_name) do
    ["#{:code.priv_dir(:ohno)}", folder, file_name]
    |> Path.join()
    |> File.read!()
  end

  def priv_json_file!(folder, file_name, opts \\ %{}) do
    read_priv_file!(folder, "#{file_name}.json")
    |> Poison.decode!(opts)
  end

  def read_file_event!(file_name) do
    priv_json_file!("webhooks", file_name)
  end

  def priv_yaml_file!(folder, file_name) do
    read_priv_file!(folder, "#{file_name}.yaml")
    |> YamlElixir.read_from_string()
    |> case do
      {:ok, map} -> map
      {:error, error} -> raise error
    end
  end

  def add!(%{id: id} = attrs, module) do
    case Repo.get(module, id) do
      %{__struct__: ^module} = r -> r
      _ -> struct(module, id: id)
    end
    |> module.changeset(Map.delete(attrs, :id))
    |> Repo.insert_or_update!()
  end

  def jq(target, query) do
    Jqish.run(target, query)
  end

  def jq!(target, query) do
    case jq(target, query) do
      {:ok, result} -> result
      {:error, error} ->
        throw error
    end
  end
end
