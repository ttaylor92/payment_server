defmodule PaymentServer.TransactionHistory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :amount, :integer
    field :user_id, :id
    field :currency_id, :id

    timestamps(type: :utc_datetime)
  end

  @available_params [:amount, :user_id, :currency_id]
  @required_params [:amount, :user_id, :currency_id]

  @doc false
  def changeset(transaction_history = %PaymentServer.TransactionHistory{}, attrs) do
    transaction_history
      |> cast(attrs, @available_params)
      |> validate_required(@required_params)
      |> validate_number(:amount, greater_than: 0)
  end
end
