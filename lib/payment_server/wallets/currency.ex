defmodule PaymentServer.Wallets.Currency do
  use Ecto.Schema
  import Ecto.Changeset

  schema "currencies" do
    field :type, :string
    field :amount, :float
    belongs_to :user, PaymentServer.Accounts.User
    has_many :transaction, PaymentServer.WalletHistory.TransactionHistory

    timestamps(type: :utc_datetime)
  end

  @available_params [:type, :amount, :user_id]
  @required_params [:type, :user_id]

  def create_changeset(params) do
    changeset(%__MODULE__{}, params)
  end

  @doc false
  def changeset(currency = %PaymentServer.Wallets.Currency{}, attrs) do
    currency
    |> cast(attrs, @available_params)
    |> validate_required(@required_params)
    |> unique_constraint(:user_id_type, name: :currencies_user_id_type_index)
  end
end
