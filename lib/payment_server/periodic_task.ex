defmodule PaymentServer.PeriodicTask do
  use GenServer
  require Logger

  alias PaymentServerWeb.WalletHelpers

  @default_interval :timer.minutes(1)
  @test_interval :timer.seconds(10)
  @interval if Mix.env() === :test, do: @test_interval, else: @default_interval

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    schedule_work()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:work, _state) do
    check_and_process_subscriptions()
    schedule_work()
    {:noreply, %{}}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @interval)
  end

  defp check_and_process_subscriptions() do
    check_all_currencies_subscriptions()
    check_currency_subscriptions()
  end

  defp check_all_currencies_subscriptions() do
    Task.start(fn -> WalletHelpers.get_all_currency_updates() end)
  end

  defp check_currency_subscriptions() do
    currencies = WalletHelpers.fetch_accepted_currencies()
      |> Enum.map(fn currency_map -> currency_map.value end)

    Enum.each(currencies, fn currency ->
      Task.start(fn -> WalletHelpers.get_currency_update(currency) end)
    end)
  end
end
