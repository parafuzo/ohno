defmodule Fabion.Repo.RepoAdapter do
  @callback statuses(String.t(), String.t(), %{}) :: {:ok, %{}} | {:error, %{}}
end
