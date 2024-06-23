defmodule PaymentServer.Currency do
  use Ecto.Schema
  import Ecto.Changeset

  schema "currencies" do
    field :type, :string
    field :amount, :integer
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, [:type, :amount])
    |> validate_required([:type, :amount])
    |> unique_constraint([:user_id, :type])
  end
end
