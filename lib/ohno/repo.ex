defmodule Ohno.Repo do
  use Ecto.Repo, otp_app: :ohno

  @doc """
  Dynamically loads the repository url from the
  OHNO_DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("OHNO_DATABASE_URL"))}
  end
end
