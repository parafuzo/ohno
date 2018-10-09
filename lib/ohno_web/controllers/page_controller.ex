defmodule OhnoWeb.PageController do
  use OhnoWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", layout: {OhnoWeb.LayoutView, "react.html"}
  end
end
