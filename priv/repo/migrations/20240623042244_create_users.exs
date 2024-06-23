defmodule PaymentServer.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :text
      add :last_name, :text
      add :email, :text

      timestamps(type: :utc_datetime)
    end
  end
end
