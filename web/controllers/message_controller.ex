defmodule Numo.MessageController do
  use Numo.Web, :controller
  import Ecto.Query

  alias Numo.Message

  plug :scrub_params, "message" when action in [:create, :update]

  def index(conn, _params) do
    query = from m in Message,
      order_by: [desc: m.inserted_at],
      limit: 1000
      
    messages =
      query
      |> Repo.all # TODO don't use all
    render(conn, "index.html", [messages: messages, queue: "all"])
  end

  def queue(conn, %{"name" => queue}) do
    query = from m in Message,
      where: m.queue == ^queue,
      order_by: [desc: m.inserted_at],
      limit: 1000

    messages =
      query
      |> Repo.all
    render(conn, "index.html", [messages: messages, queue: queue])
  end

  def new(conn, _params) do
    changeset = Message.changeset(%Message{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"message" => message_params}) do
    changeset = Message.changeset(%Message{}, message_params)

    case Repo.insert(changeset) do
      {:ok, _message} ->
        conn
        |> put_flash(:info, "Message created successfully.")
        |> redirect(to: message_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    message = Repo.get!(Message, id)
    render(conn, "show.html", message: message)
  end

  def edit(conn, %{"id" => id}) do
    message = Repo.get!(Message, id)
    changeset = Message.changeset(message)
    render(conn, "edit.html", message: message, changeset: changeset)
  end

  def update(conn, %{"id" => id, "message" => message_params}) do
    message = Repo.get!(Message, id)
    changeset = Message.changeset(message, message_params)

    case Repo.update(changeset) do
      {:ok, message} ->
        conn
        |> put_flash(:info, "Message updated successfully.")
        |> redirect(to: message_path(conn, :show, message))
      {:error, changeset} ->
        render(conn, "edit.html", message: message, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    message = Repo.get!(Message, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(message)

    conn
    |> put_flash(:info, "Message deleted successfully.")
    |> redirect(to: message_path(conn, :index))
  end
end
