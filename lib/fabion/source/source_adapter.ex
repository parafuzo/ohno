defmodule Fabion.Source.SourceAdapter do
  @callback statuses(String.t(), String.t(), %{}) :: {:ok, %{}} | {:error, %{}}
end
