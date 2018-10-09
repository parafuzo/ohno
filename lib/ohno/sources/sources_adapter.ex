defmodule Ohno.Sources.SourcesAdapter do
  @callback client() :: Tesla.Client.t()
  @callback statuses(Tesla.Client.t(), String.t(), String.t(), %{}) :: {:ok, %{}} | {:error, Tesla.Env.t()}
  @callback get_file(Tesla.Client.t(), String.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, Tesla.Env.t()}
end
