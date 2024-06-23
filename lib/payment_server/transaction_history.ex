defmodule PaymentServer.TransactionHistory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :amount, :integer
    field :user, :id
    field :currency, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction_history, attrs) do
    transaction_history
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
  end
end
