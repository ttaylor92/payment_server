defmodule PaymentServer.Support.WalletFactory do
  @behaviour FactoryEx

  def schema, do: PaymentServer.Wallets.Currency

  def repo, do: PaymentServer.Repo

  def build(params \\ %{}) do
    default = %{
      type: "USD",
      amount: 10000.00,
    }

    Map.merge(default, params)
  end

  def build_param_map(params \\ %{}) do
    FactoryEx.build_params(__MODULE__, params)
  end
end
