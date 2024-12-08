defmodule PaymentServer.Repo.Migrations.UpdateRatesTable do
  use Ecto.Migration

  def change do
    rename table(:rates), :currency, to: :currency_to
    rename table(:rates), :from_currency, to: :currency_from
    rename table(:rates), :value, to: :rate
  end
end
