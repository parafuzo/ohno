defmodule Fabion.Builder do
  import ShorterMaps

  alias Fabion.Repo
  alias Fabion.Accounts
  alias Fabion.Enqueuer
  alias Fabion.Sources
  alias Fabion.Builder.GetStagesJob
  alias Fabion.Builder.Pipeline

  def add_pipeline("push", %{"repository" => ~m{url}, "sender" => sender} = params) do
    with {:ok, %{id: repository_id}} <- Sources.repo_by_url(url),
         {:ok, %{id: sender_id}} <- Accounts.user_from_sender(sender),
         {:ok, ~M{id} = event} <-
           ~M{from_type: :PUSH_EVENT, repository_id, sender_id, params}
           |> Pipeline.changeset()
           |> Repo.insert(),
         {:ok, _} <- Enqueuer.push({GetStagesJob, id}) do
      {:ok, event}
    end
  end
end
