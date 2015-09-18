defmodule Numo.Repo.Migrations.AddFieldsToMessage do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :error_code, :binary
      add :queue, :string
    end
  end
end
