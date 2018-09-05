defmodule FabionWeb.LayoutView do
  use FabionWeb, :view

  def js_from_manifest(conn) do
    ["#{:code.priv_dir(:fabion)}", "static", "manifest.json"]
    |> Path.join()
    |> File.read!()
    |> Poison.decode!()
    |> Enum.sort(fn _, {_, file} -> !(file =~ ~r{^/https?://.*\.js$}) end)
    |> Enum.reduce([], &make_tags(conn, &1, &2))
    |> Enum.join("\n")
  end

  defp make_tags(conn, {_, file}, acc) do
    cond do
      file =~ ~r{^/https?://.*\.js$} ->
        <<_::binary-size(1), url::binary>> = file
        acc ++ [js_tag(url)]

      file =~ ~r{^/.*\.js$} ->
        acc ++ [js_tag(static_path(conn, file))]

      true ->
        acc
    end
  end

  defp js_tag(src) do
    "<script src=\"#{src}\"></script>"
  end
end
