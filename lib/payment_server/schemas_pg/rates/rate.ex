defmodule PaymentServer.SchemasPg.Rates.Rate do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
    currency: String.t(),
    from_currency: String.t(),
    value: float()
  }

  @required_params [:currency, :value]
  @available_params []

  schema "rates" do
    field :currency, :string
    field :from_currency, :string, default: "USD"
    field :value, :float

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
    |> validate_fields_not_equal(:currency, :from_currency)
    |> update_change(:currency, &String.upcase(&1))
    |> update_change(:from_currency, &String.upcase(&1))
  end

  def update_changeset(%__MODULE__{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:amount, :type])
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
