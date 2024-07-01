defmodule PaymentServer.Repo.Migrations.AddWalletUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index(:currencies, [:user_id, :type])
  end
end
