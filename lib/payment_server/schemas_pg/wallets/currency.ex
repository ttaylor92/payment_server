defmodule PaymentServer.SchemasPg.Wallets.Currency do
  use Ecto.Schema
  import Ecto.Changeset
  alias PaymentServer.SchemasPg.Accounts.User

  @type t :: %__MODULE__{
    type: String.t(),
    amount: integer(),
    user: User.t()
  }

  schema "currencies" do
    field :type, :string
    field :amount, :float
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @available_params [:type, :user_id, :amount]
  @required_params [:type, :user_id]

  def create_changeset(params) do
    changeset(%__MODULE__{}, params)
  end

  @doc false
  def changeset(%__MODULE__{} = currency, attrs) do
    currency
    |> cast(attrs, @available_params)
    |> validate_required(@required_params)
    |> unique_constraint(:user_id_type, name: :currencies_user_id_type_index)
  end

  def update_changeset(%__MODULE__{} = changeset, attrs) do
    cast(changeset, attrs, [:amount, :type])
  end
end
