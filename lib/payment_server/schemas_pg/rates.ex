defmodule PaymentServer.SchemasPg.Rates do

  alias EctoShorts.Actions
  alias PaymentServer.SchemasPg.Rates.Rate

  @type response :: {:ok, Rate.t()} | {:error, Ecto.Changeset.t()}

  @spec create(map()):: response()
  def create(params) do
    Actions.create(Rate, params)
  end

  @spec list_rates(map()) :: list(Rate.t())
  def list_rates(params \\ %{}) do
    Actions.all(Rate, params)
  end

  @spec find_by_currency(String.t()) :: {:ok, Rate.t()} | {:error, any()}
  def find_by_currency(currency) do
    Actions.find(Rate, %{currency: currency})
  end
end
