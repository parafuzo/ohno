defmodule FabionWeb.WebHookController do
  use FabionWeb, :controller

  def index(conn, params) do
    # params |> IO.inspect
    [event] = get_req_header(conn, "x-github-event") |> IO.inspect
    handle(event, conn, params)
  end

  # defp handle("push", conn, _params) do
  # end

  defp handle("ping", conn, _params) do
    json conn, %{ message: "pong ;)" }
  end

  defp handle(event, conn, _params) do
    conn
      |> put_status(400)
      |> json(%{ error: "Unsupported event type: #{event}"})
      |> halt()
  end
end
