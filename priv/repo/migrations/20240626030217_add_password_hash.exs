defmodule PaymentServer.Repo.Migrations.AddPasswordHash do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_hash, :text
    end

    create unique_index(:users, [:email])
  end
end
