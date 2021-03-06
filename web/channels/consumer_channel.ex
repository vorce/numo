defmodule Numo.ConsumerChannel do
  use Phoenix.Channel

  def join("consumer:all", _auth_msg, socket) do
    {:ok, socket}
  end

  def handle_in("new_consumer", msg, socket) do
    broadcast! socket, "new_consumer", msg
    {:noreply, socket}
  end

  def handle_in("msg_count", msg, socket) do
    broadcast! socket, "msg_count", msg
    {:noreply, socket}
  end

  #def handle_out("new_msg", payload, socket) do
  #  push socket, "new_msg", payload
  #  {:noreply, socket}
  #end
end
