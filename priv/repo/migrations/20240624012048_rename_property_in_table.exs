defmodule PaymentServer.Repo.Migrations.RenamePropertyInTable do
  use Ecto.Migration

  def change do
    rename table(:currencies), :user, to: :user_id
  end
end
