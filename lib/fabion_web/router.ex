defmodule FabionWeb.Router do
  use FabionWeb, :router

  pipeline :webhook do
    plug :accepts, ["json"]
  end

  scope "/webhook", FabionWeb do
    pipe_through :webhook
    post "/", WebHookController, :index
  end
end
