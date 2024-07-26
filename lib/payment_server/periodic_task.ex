defmodule PaymentServer.PeriodicTask do
  use GenServer

  alias PaymentServer.Wallets.Helpers

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    schedule_work()
    {:ok, %{user_ids: []}}
  end

  @impl true
  def handle_info(:work, state) do
    Enum.each(state.user_ids, fn user_id ->
      Helpers.get_total_worth(user_id)
    end)
    schedule_work()
    {:noreply, state}
  end

  @impl true
  def handle_cast({:add_user_id, user_id}, state) do
    new_state = Map.update(state, :user_ids, [user_id], fn user_ids -> [user_id | user_ids] end)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:remove_user_id, user_id}, state) do
    new_state = Map.update!(state, :user_ids, fn user_ids -> List.delete(user_ids, user_id) end)
    {:noreply, new_state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 60_000) # Schedule work to be done in 60 seconds
  end

  # Public API to add a user ID
  def add_user_id(user_id) do
    IO.inspect(user_id, label: "Adding user: #{user_id}")
    GenServer.cast(__MODULE__, {:add_user_id, user_id})
  end

  # Public API to remove a user ID
  def remove_user_id(user_id) do
    IO.inspect(user_id, label: "Removing user: #{user_id}")
    GenServer.cast(__MODULE__, {:remove_user_id, user_id})
  end
end
