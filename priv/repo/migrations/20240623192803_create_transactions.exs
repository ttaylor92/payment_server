defmodule PaymentServer.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :amount, :integer
      add :user, references(:users, on_delete: :delete_all)
      add :currency, references(:currencies, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:user])
    create index(:transactions, [:currency])
  end
end
