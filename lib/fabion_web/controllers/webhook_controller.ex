defmodule FabionWeb.WebhookController do
  use FabionWeb, :controller

  alias Fabion.Builder
  alias Fabion.Builder.Pipeline

  alias Ecto.Changeset
  import Kronky.Payload

  def index(conn, params) do
    # params |> Poison.encode!() |> IO.puts()
    # |> IO.inspect()
    [event] = get_req_header(conn, "x-github-event")
    handle_event(event, params) |> response(conn)
  end

  defp handle_event(event = "push", params) do
    Builder.add_pipeline(event, params)
  end

  defp handle_event("ping", _params) do
    {:ok, "pong ;)"}
  end

  defp handle_event(event, _params) do
    {:error, "Unsupported event type: #{event}"}
  end

  defp response(status, body, conn) when is_integer(status) do
    conn
    |> put_status(status)
    |> json(body)
    |> halt()
  end

  defp response({:ok, %Pipeline{id: id}}, conn) do
    response({:ok, %{id: id}}, conn)
  end

  defp response({:ok, result}, conn) do
    response(200, success_payload(result), conn)
  end

  defp response({:error, %Changeset{} = changeset}, conn) do
    response(changeset, conn)
  end

  defp response(result, conn) do
    response(400, convert_to_payload(result), conn)
  end
end
