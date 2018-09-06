defmodule Fabion.Sources.SourcesAdapter do
  @callback statuses(String.t(), String.t(), %{}) :: {:ok, %{}} | {:error, %{}}
end
