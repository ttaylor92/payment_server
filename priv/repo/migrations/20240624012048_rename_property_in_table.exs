defmodule PaymentServer.Repo.Migrations.RenamePropertyInTable do
  use Ecto.Migration

  def change do
    rename table(:currencies), :user, to: :user_id
    rename table(:transactions), :user, to: :user_id
    rename table(:transactions), :currency, to: :currency_id
  end
end
