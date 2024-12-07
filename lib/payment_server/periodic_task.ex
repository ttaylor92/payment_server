defmodule PaymentServer.PeriodicTask do
  use GenServer
  require Logger

  alias PaymentServer.WalletService

  @interval if Mix.env() === :test, do: :timer.seconds(10), else: :timer.minutes(1)

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, %{}, opts)
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
    Task.start(fn -> WalletService.get_all_currency_updates() end)
  end

  defp check_currency_subscriptions() do
    WalletService.fetch_accepted_currencies()
    |> Enum.each(fn currency ->
      Task.start(fn -> WalletService.get_currency_update(currency.value) end)
    end)
  end
end
