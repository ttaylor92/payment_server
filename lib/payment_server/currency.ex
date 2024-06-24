defmodule PaymentServer.Currency do
  use Ecto.Schema
  import Ecto.Changeset

  schema "currencies" do
    field :type, :string
    field :amount, :integer
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @available_params [:type, :amount, :user_id]
  @required_params [:type, :amount, :user_id]

  @doc false
  def changeset(currency = %PaymentServer.Currency{}, attrs) do
    currency
    |> cast(attrs, @available_params)
    |> validate_required(@required_params)
    |> unique_constraint([:user, :type])
    |> validate_number(:amount, greater_than: 0)
  end
end
