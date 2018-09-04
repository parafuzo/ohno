defmodule Fabion.Source do
  @adapter Keyword.get(Application.get_env(:fabion, __MODULE__), :adapter, Fabion.Source.GithubAdapter)

  defdelegate statuses(repo, commit_sha, parameters), to: @adapter
end