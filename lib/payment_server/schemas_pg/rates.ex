defmodule PaymentServer.SchemasPg.Rates do

  alias EctoShorts.Actions
  alias PaymentServer.SchemasPg.Rates.Rate

  @type response :: {:ok, Rate.t()} | {:error, Ecto.Changeset.t()}

  @spec create(map()):: response()
  def create(params) do
    Actions.create(Rate, params)
  end

  @spec list_rates(list() | map()) :: list(Rate.t())
  def list_rates(params) do
    Actions.all(Rate, params)
  end

  @spec find_by_currency(String.t()) :: Rate.t() | nil
  def find_by_currency(currency) do
    case Actions.all(Rate, %{currency: currency, last: 1}) do
      [] -> nil
      rates_list -> List.first(rates_list)
    end
  end
end
