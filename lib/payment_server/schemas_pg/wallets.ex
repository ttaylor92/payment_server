defmodule PaymentServer.SchemasPg.Wallets do
  import Ecto.Query, warn: false

  alias Faker.Currency
  alias Faker.Currency
  alias EctoShorts.Actions
  alias PaymentServer.Repo
  alias PaymentServer.SchemasPg.Wallets.Currency

  @spec create(map()) :: {:ok, Currency.t()} | {:error, Ecto.Changeset.t()}
  @spec create(map(), keyword()) :: {:ok, Currency.t()} | {:error, Ecto.Changeset.t()}
  def create(params \\ %{}, options \\ []) do
    Currency
    |> Actions.create(params)
    |> maybe_preload(options)
  end

  @spec update(Currency.t(), map()) :: {:ok, Currency.t()} | {:error, Ecto.Schema.t()}
  @spec update(Currency.t(), map(), keyword()) :: {:ok, Currency.t()} | {:error, Ecto.Schema.t()}
  def update(%Currency{} = changeset, params, options \\ []) do
    Currency
    |> Actions.update(changeset, params)
    |> maybe_preload(options)
  end

  @spec delete(Currency.t()) :: {:ok, Currency.t()} | {:error, Ecto.Schema.t()}
  def delete(params) do
    Actions.delete(params)
  end

  @spec get_by_id(String.t() | integer()) :: {:ok, Currency.t()} | {:error, String.t()}
  @spec get_by_id(String.t() | integer(), keyword()) :: {:ok, Currency.t()} | {:error, String.t()}
  def get_by_id(id, options \\ []) do
    case Actions.get(Currency, id) do
      nil -> {:error, "Wallet not found"}
      user -> maybe_preload({:ok, user}, options)
    end
  end

  @spec find_wallet(map()) :: {:ok, Currency.t()} | {:error, String.t()}
  @spec find_wallet(map(), keyword()) :: {:ok, Currency.t()} | {:error, String.t()}
  def find_wallet(params, options \\ []) do
    Currency
    |> Actions.find(params)
    |> maybe_preload(options)
  end

  @spec get_all(map()) :: list(Currency.t())
  def get_all(params) do
    Actions.all(Currency, params)
  end

  defp maybe_preload({:error, data}, _opts) do
    {:error, data}
  end

  defp maybe_preload({:ok, schema_data}, opts) do
    case opts[:preload] do
      nil -> {:ok, schema_data}
      preload -> {:ok, Repo.preload(schema_data, preload)}
    end
  end
end
