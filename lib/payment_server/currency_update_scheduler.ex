defmodule PaymentServer.CurrencyUpdateScheduler do
  use GenServer
  require Logger

  alias PaymentServer.WalletService

  @interval if Mix.env() === :test, do: :timer.seconds(10), else: :timer.minutes(1)
  @default_name __MODULE__

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @default_name)
    initial_state = %{
      rates: [],
      updated_at: nil,
      ref: nil
    }
    GenServer.start_link(__MODULE__, initial_state, opts)
  end

  @impl true
  def init(state) do
    schedule_work()
    {:ok, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, @interval)
  end

  @impl true
  def handle_info(:work, state) do
    task =
      Task.Supervisor.async_nolink(PaymentServer.TaskSupervisor, fn ->
        WalletService.get_all_currency_updates(state)
      end)

    schedule_work()
    {:noreply, %{state | ref: task.ref}}
  end

  @impl true
  def handle_info({ref, result}, state) do
    Process.demonitor(ref, [:flush])

    updated_state = state
      |> Map.put(:rates, result.rates)
      |> Map.put(:updated_at, result.updated_at)
      |> Map.put(:ref, nil)

    {:noreply, updated_state}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    Logger.info("The process has failed unexpectedly: #{inspect(ref)}")
    {:noreply, %{state | ref: nil}}
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

  def update_state(new_state, name \\ @default_name) do
    GenServer.cast(name, {:update_state, new_state})
  end
end
