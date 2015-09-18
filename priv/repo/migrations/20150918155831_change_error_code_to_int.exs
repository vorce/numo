defmodule Numo.Repo.Migrations.ChangeErrorCodeToInt do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      remove :error_code
      add :error_code, :integer
    end
  end
end
