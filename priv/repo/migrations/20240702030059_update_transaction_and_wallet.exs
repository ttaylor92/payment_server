defmodule PaymentServer.Repo.Migrations.UpdateTransactionAndWallet do
  use Ecto.Migration

  def change do
    alter table(:currencies) do
      modify :amount, :float, default: 0
    end

    alter table(:transactions) do
      add :reciever_id, references(:users, on_delete: :nothing)
    end
  end
end
