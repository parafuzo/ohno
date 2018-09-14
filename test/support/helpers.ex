defmodule Fabion.Support.Helpers do
  def read_file_event!(file_name) do
    ["#{:code.priv_dir(:fabion)}", "webhooks", "#{file_name}.json"]
    |> Path.join()
    |> File.read!()
    |> Poison.decode!()
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
