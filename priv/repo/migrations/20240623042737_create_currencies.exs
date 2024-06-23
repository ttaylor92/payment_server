defmodule PaymentServer.Repo.Migrations.CreateCurrencies do
  use Ecto.Migration

  def change do
    create table(:currencies) do
      add :type, :text
      add :amount, :integer
      add :user, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:currencies, [:user])
  end
end
