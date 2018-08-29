defmodule FabionWeb.PageController do
  use FabionWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
