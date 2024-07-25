defmodule PaymentServer.Repo.Migrations.AddUserDefaultCurrency do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :default_currency, :text, default: "USD"
    end
  end
end
