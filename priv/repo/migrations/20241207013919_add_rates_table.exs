defmodule PaymentServer.Repo.Migrations.AddRatesTable do
  use Ecto.Migration

  def change do
    create table(:rates) do
      add :currency, :text
      add :from_currency, :text, default: "USD"
      add :value, :float

      timestamps(type: :utc_datetime)
    end

    create index(:rates, [:currency])
  end
end
