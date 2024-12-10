defmodule PaymentServer.SchemasPg.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias PaymentServer.SchemasPg.Wallets.Currency

  @type t :: %__MODULE__{
    id: integer(),
    first_name: String.t(),
    last_name: String.t(),
    email: String.t(),
    default_currency: String.t(),
    password_hash: String.t(),
    password: String.t() | nil,
    password_confirmation: String.t() | nil,
    inserted_at: DateTime.t(),
    updated_at: DateTime.t(),
    curriences: list(Currency.t())
  }

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :default_currency, :string, default: "USD"
    field :password_hash, :string, redact: true
    field :password, :string, virtual: true, redact: true
    field :password_confirmation, :string, virtual: true, redact: true
    has_many :curriences, Currency

    timestamps(type: :utc_datetime)
  end

  @available_params [
    :first_name,
    :last_name,
    :email,
    :password,
    :password_confirmation,
    :default_currency
  ]
  @required_params [:first_name, :last_name, :email, :password, :password_confirmation]

  @doc false
  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, @available_params)
    |> validate_format(:email, ~r/@/)
    |> update_change(:email, &String.downcase(&1))
    |> unique_constraint(:email)
    |> validate_length(:first_name, min: 2, max: 20)
    |> validate_length(:last_name, min: 2, max: 20)
    |> validate_length(:password, min: 6, max: 20)
    |> validate_confirmation(:password)
    |> hash_password
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Argon2.hash_pwd_salt(password))
  end

  defp hash_password(changeset), do: changeset

  def create_changeset(params) do
    %__MODULE__{}
    |> changeset(params)
    |> validate_required(@required_params)
  end

  def update_changeset(%__MODULE__{} = changeset, params) do
    changeset(changeset, params)
  end

  def query_by_id(id) do
    from(u in __MODULE__, where: u.id == ^id, preload: [:curriences])
  end
end
