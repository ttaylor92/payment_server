defmodule PaymentServer.PeriodicTask do
  use GenServer
  require Logger

  alias PaymentServerWeb.WalletHelpers

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    schedule_work()
    {:ok, %{user_ids: [], currency_user_ids: [], all_currencies: []}}
  end

  @impl true
  def handle_info(:work, state) do
    process_user_ids(state.user_ids, &WalletHelpers.get_total_worth/1)
    process_currency_user_ids(state.currency_user_ids, &WalletHelpers.get_currency_update/2)
    process_user_ids(state.all_currencies, &WalletHelpers.get_all_currency_updates/1)
    schedule_work()
    {:noreply, state}
  end

  defp process_user_ids(user_ids, fun) do
    Enum.each(user_ids, fn user_id ->
      Task.start(fn -> fun.(user_id) end)
    end)
  end

  defp process_currency_user_ids(currency_user_ids, fun) do
    Enum.each(currency_user_ids, fn [user_id, currency] ->
      Task.start(fn -> fun.(user_id, currency) end)
    end)
  end

  @impl true
  def handle_cast({:add_user_id, type, user_id}, state) do
    new_state = update_user_ids(state, type, user_id)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:remove_user_id, type, user_id}, state) do
    new_state = delete_user_id_from_state(state, type, user_id)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:add_user_id, :watch_currency, user_id, currency}, state) do
    new_state = update_currency_user_ids(state, user_id, currency)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:remove_user_id, :watch_currency, user_id, currency}, state) do
    new_state = delete_currency_user_id_from_state(state, user_id, currency)
    {:noreply, new_state}
  end

  defp update_user_ids(state, type, user_id) do
    key = user_id_key(type)
    if Enum.member?(Map.get(state, key), user_id) do
      state
    else
      Map.update!(state, key, fn user_ids -> [user_id | user_ids] end)
    end
  end

  defp delete_user_id_from_state(state, type, user_id) do
    key = user_id_key(type)
    Map.update!(state, key, fn user_ids -> List.delete(user_ids, user_id) end)
  end

  defp user_id_key(:notification), do: :user_ids
  defp user_id_key(:all_currencies), do: :all_currencies

  defp update_currency_user_ids(state, user_id, currency) do
    if Enum.member?(state.currency_user_ids, [user_id, currency]) do
      state
    else
      Map.update!(state, :currency_user_ids, fn user_ids -> [[user_id, currency] | user_ids] end)
    end
  end

  defp delete_currency_user_id_from_state(state, user_id, currency) do
    Map.update!(state, :currency_user_ids, fn user_ids ->
      Enum.reject(user_ids, fn id_combo -> id_combo == [user_id, currency] end)
    end)
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 60_000) # Schedule work to be done in 60 seconds
  end

  # Public API to add a user ID
  def add_user_id(type, user_id) do
    GenServer.cast(__MODULE__, {:add_user_id, type, user_id})
  end

  # Public API to add a user ID for watching currency changes
  def add_user_id(type, user_id, currency) when type == :watch_currency do
    GenServer.cast(__MODULE__, {:add_user_id, type, user_id, currency})
  end

  # Public API to remove a user ID
  def remove_user_id(type, user_id) do
    GenServer.cast(__MODULE__, {:remove_user_id, type, user_id})
  end

  # Public API to remove a user ID for watching currency changes
  def remove_user_id(type, user_id, currency) when type == :watch_currency do
    GenServer.cast(__MODULE__, {:remove_user_id, type, user_id, currency})
  end
end
