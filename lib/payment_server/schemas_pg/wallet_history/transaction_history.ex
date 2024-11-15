defmodule PaymentServer.SchemasPg.WalletHistory.TransactionHistory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :amount, :integer
    field :type, :string
    belongs_to :currency, PaymentServer.SchemasPg.Wallets.Currency
    belongs_to :user, PaymentServer.SchemasPg.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @available_params [:amount, :user_id, :currency_id, :type]
  @required_params [:amount, :user_id, :currency_id, :type]
  @accepted_types ["sent", "received"]

  def create_changeset(params) do
    changeset(%__MODULE__{}, params)
  end

  @doc false
  def changeset(transaction_history = %PaymentServer.SchemasPg.WalletHistory.TransactionHistory{}, attrs) do
    transaction_history
    |> cast(attrs, @available_params)
    |> validate_required(@required_params)
    |> validate_number(:amount, greater_than: 0)
    |> validate_inclusion(:type, @accepted_types)
  end
end
