defmodule PaymentServer.SchemasPg.Rates.Rate do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
    currency_to: String.t(),
    currency_from: String.t(),
    rate: float()
  }

  @required_params [:currency_to, :rate]
  @available_params []

  schema "rates" do
    field :currency_to, :string
    field :currency_from, :string, default: "USD"
    field :rate, :float

    timestamps(type: :utc_datetime)
  end

  def create_changeset(params) do
    changeset(%__MODULE__{}, params)
  end

  @doc false
  def changeset(%__MODULE__{} = currency, attrs) do
    currency
    |> cast(attrs, @available_params ++ @required_params)
    |> validate_required(@required_params)
    |> validate_fields_not_equal(:currency_to, :currency_from)
    |> update_change(:currency_to, &String.upcase(&1))
    |> update_change(:currency_from, &String.upcase(&1))
  end

  defp validate_fields_not_equal(changeset, field1, field2) do
    value1 = get_field(changeset, field1)
    value2 = get_field(changeset, field2)

    if value1 == value2 do
      add_error(changeset, field1, "#{field1} must not equal #{field2}")
    else
      changeset
    end
  end

end
