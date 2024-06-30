defmodule PaymentServer.WalletHistory.TransactionHistory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :amount, :integer
    field :type, :string
    field :currency_id, :id
    belongs_to :user, PaymentServer.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @available_params [:amount, :user_id, :currency_id]
  @required_params [:amount, :user_id, :currency_id]

  def create_changeset(params) do
    changeset(%__MODULE__{}, params)
  end

  @doc false
  def changeset(transaction_history = %PaymentServer.WalletHistory.TransactionHistory{}, attrs) do
    transaction_history
      |> cast(attrs, @available_params)
      |> validate_required(@required_params)
      |> validate_number(:amount, greater_than: 0)
  end
end
