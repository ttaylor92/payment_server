defmodule PaymentServer.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password_hash, :string, redact: true
    field :password, :string, virtual: true, redact: true
    field :password_confirmation, :string, virtual: true, redact: true
    has_many :transactions, PaymentServer.WalletHistory.TransactionHistory
    has_many :curriences, PaymentServer.Wallets.Currency

    timestamps(type: :utc_datetime)
  end

  @available_params [:first_name, :last_name, :email, :password, :password_confirmation]
  @required_params [:first_name, :last_name, :email, :password, :password_confirmation]

  @doc false
  def changeset(user = %PaymentServer.Accounts.User{}, attrs) do
    user
    |> cast(attrs, @available_params)
    |> validate_required(@required_params)
    |> validate_format(:email, ~r/@/)
    |> update_change(:email, &String.downcase(&1))
    |> unique_constraint(:email)
    |> validate_length(:first_name, min: 2, max: 20)
    |> validate_length(:last_name, min: 2, max: 20)
    |> validate_length(:password, min: 6, max: 20)
    |> validate_confirmation(:password)
    |> hash_password
  end

  defp hash_password(%Ecto.Changeset{ valid?: true, changes: %{ password: password }} = changeset) do
    change(changeset, password_hash: Argon2.hash_pwd_salt(password))
  end

  defp hash_password(changeset), do: changeset

  def create_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
