defmodule Numo.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :message_id, :string
      add :reason, :string
      add :payload, :text
      add :metadata, :text

      timestamps
    end

  end
end
