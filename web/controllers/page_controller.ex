defmodule Numo.PageController do
  use Numo.Web, :controller

  def index(conn, _params) do
    consumers = Supervisor.which_children(Numo.Supervisor)
      |> Enum.filter(fn({m, pid, _, _}) -> m == Consumer.Json end)
    render(conn, "index.html", consumers: consumers)
  end
end
