defmodule Ohno.GothConfig do
  use Goth.Config

  def init(config) do
    json = Confex.fetch_env!(:goth, :json_env)
    {:ok, Keyword.put(config, :json, json)}
  end
end
