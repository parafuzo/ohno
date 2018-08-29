defmodule Fabion.Repo do
  use Ecto.Repo, otp_app: :fabion

  @doc """
  Dynamically loads the repository url from the
  FABION_DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("FABION_DATABASE_URL"))}
  end
end
