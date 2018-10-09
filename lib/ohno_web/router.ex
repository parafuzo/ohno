defmodule OhnoWeb.Router do
  use OhnoWeb, :router

  pipeline :graphql do
  end

  pipeline :webhook do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/graphql" do
    pipe_through :graphql

    forward "/ui", Absinthe.Plug.GraphiQL,
      schema: OhnoWeb.Graphql.Schema,
      # socket: BrokerWeb.UserSocket,
      interface: :playground

    forward "/", Absinthe.Plug,
      schema: OhnoWeb.Graphql.Schema
  end

  scope "/webhook", OhnoWeb do
    pipe_through :webhook
    post "/", WebhookController, :index
  end

  scope "/", OhnoWeb do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
  end
end
