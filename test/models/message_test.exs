defmodule Numo.MessageTest do
  use Numo.ModelCase

  alias Numo.Message

  @valid_attrs %{message_id: "some content", metadata: "some content", payload: "some content", reason: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Message.changeset(%Message{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Message.changeset(%Message{}, @invalid_attrs)
    refute changeset.valid?
  end
end
