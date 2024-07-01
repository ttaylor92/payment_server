defmodule PaymentServer.Repo.Migrations.AddTypeToTransaction do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :type, :text
    end
  end
end
