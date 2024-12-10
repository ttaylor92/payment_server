defmodule PaymentServer.PeriodicTaskTest do
  use ExUnit.Case, async: true
  alias PaymentServer.PeriodicTask

  describe "periodicTask" do
    setup do
      {:ok, pid} = PeriodicTask.start_link(name: nil)
      %{pid: pid}
    end

    test "storing and fetching rates", %{pid: pid} do
      rates = [%{currency: "USD", value: 1.0}, %{currency: "EUR", value: 0.9}]

      # Update the state with new rates
      PeriodicTask.update_state(rates, pid)

      # Fetch the state
      state = PeriodicTask.get_state(pid)

      # Assert that the fetched state matches the updated rates
      assert state.rates === rates
    end

    test "updated_at field reflects time of update", %{pid: pid} do
      rates = [%{currency: "USD", value: 1.0}, %{currency: "EUR", value: 0.9}]

      # Update the state with new rates
      PeriodicTask.update_state(rates, pid)

      # Fetch the state
      state = PeriodicTask.get_state(pid)

      # Assert that the updated_at field is not nil and is close to the current time
      assert state.updated_at !== nil
      assert DateTime.diff(DateTime.utc_now(), state.updated_at, :second) < 1
    end
  end
end
