defmodule Numo.PageController do
  use Numo.Web, :controller

  def index(conn, _params) do
    consumers = Supervisor.which_children(Numo.Supervisor)
      |> Enum.filter(fn({_name, _, _, [h|t]}) -> h == Consumer.Json end)
    render(conn, "index.html", consumers: consumers)
  end
end
