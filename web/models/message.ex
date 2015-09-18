defmodule Numo.Message do
  use Numo.Web, :model

  schema "messages" do
    field :message_id, :string
    field :reason, :string
    field :payload, :string
    field :metadata, :string
    field :error_code, :integer
    field :queue, :string

    timestamps
  end

  @required_fields ~w(message_id reason payload metadata error_code queue)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
