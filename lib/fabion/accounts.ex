defmodule Fabion.Accounts do
  import ShorterMaps

  alias Fabion.Repo
  alias Fabion.Accounts.GithubUser

  def user_from_sender(~m{node_id, login, html_url, avatar_url}) do
    case Repo.get_by(GithubUser, node_id: node_id) do
      %GithubUser{} = user -> user
      _ -> %GithubUser{}
    end
    |> GithubUser.changeset(~M{node_id, login, html_url, avatar_url})
    |> Repo.insert_or_update()
  end

  def user_from_sender(sender) do
    {:error, {:sender, {"invalid sender to create user", sender: sender}}}
  end
end
