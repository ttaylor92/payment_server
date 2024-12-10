defmodule PaymentServer.PeriodicTask do
  use GenServer
  require Logger

  alias PaymentServer.WalletService

  @interval if Mix.env() === :test, do: :timer.seconds(10), else: :timer.minutes(1)
  @default_name __MODULE__

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @default_name)
    initial_state = %{
      rates: [],
      updated_at: nil
    }
    GenServer.start_link(__MODULE__, initial_state, opts)
  end

  @impl true
  def init(state) do
    schedule_work()
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    check_all_currencies_subscriptions()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @interval)
  end

  defp check_all_currencies_subscriptions() do
    Task.start(fn -> WalletService.get_all_currency_updates() end)
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:update_state, new_state}, _state) do
    {:noreply, new_state}
  end

  def get_state(name \\ @default_name) do
    GenServer.call(name, :get_state)
  end

  def update_state(_, name \\ @default_name)
  def update_state(rates, name) when is_list(rates) do
    timestamp = DateTime.utc_now()
    new_state = %{rates: rates, updated_at: timestamp}
    GenServer.cast(name, {:update_state, new_state})
  end

  def update_state(_, _name) do
    {:noreplay, %{}}
  end
end
