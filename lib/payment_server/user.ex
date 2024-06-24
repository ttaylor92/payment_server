defmodule PaymentServer.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    has_many :transactions, PaymentServer.TransactionHistory
    has_many :curriences, PaymentServer.Currency

    timestamps(type: :utc_datetime)
  end

  @available_params [:first_name, :last_name, :email]
  @required_params [:first_name, :last_name, :email]

  @doc false
  def changeset(user = %PaymentServer.User{}, attrs) do
    user
    |> cast(attrs, @available_params)
    |> validate_required(@required_params)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
  end
end
