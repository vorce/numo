defmodule Numo.StatusController do
  use Numo.Web, :controller

  def status(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> json %{version: "0.0.1", inRecovery: false,
              statusCode: 200, message: "Operational"}
  end
end