defmodule Numo.Repo do
  use Ecto.Repo, otp_app: :numo
  
  # This seems to cause strangeness like:
  """
  ** (ArithmeticError) bad argument in arithmetic expression
    (numo) lib/numo/repo.ex:3: Numo.Repo.log/1
    (ecto) lib/ecto/adapters/sql.ex:540: Ecto.Adapters.SQL.transaction/3
  """
  #use Beaker.Integrations.Ecto
end
