defmodule PaymentServer.Repo.Migrations.AddDefaultAmount do
  use Ecto.Migration

  def change do
    alter table(:currencies) do
      modify :amount, :decimal, default: 0
    end
  end
end
