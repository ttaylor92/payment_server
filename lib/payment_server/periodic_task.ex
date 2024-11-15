defmodule PaymentServer.PeriodicTask do
  use GenServer
  require Logger

  alias PaymentServer.Services.WalletService

  @default_name __MODULE__
  @interval if Mix.env() === :test, do: :timer.seconds(10), else: :timer.minutes(1)

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @default_name)
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  @impl true
  def init(state) do
    schedule_work()
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    check_and_process_subscriptions()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @interval)
  end

  defp check_and_process_subscriptions() do
    check_all_currencies_subscriptions()
    check_currency_subscriptions()
  end

  defp check_all_currencies_subscriptions() do
    Task.start(fn -> WalletService.get_all_currency_updates() end)
  end

  defp check_currency_subscriptions() do
    WalletService.fetch_accepted_currencies()
    |> Enum.map(fn currency_map -> currency_map.value end)
    |> Enum.each(fn currency ->
      Task.start(fn -> WalletService.get_currency_update(currency) end)
    end)
  end
end
