defmodule PaymentServer.CurrencyUpdateSchedulerTest do
  use ExUnit.Case, async: true
  alias PaymentServer.CurrencyUpdateScheduler

  describe "CurrencyUpdateScheduler" do
    setup do
      {:ok, pid} = CurrencyUpdateScheduler.start_link(name: nil)
      %{pid: pid}
    end

    test "storing and fetching rates", %{pid: pid} do
      rates = [%{currency: "USD", value: 1.0}, %{currency: "EUR", value: 0.9}]

      # Update the state with new rates
      timestamp = DateTime.utc_now()
      new_state = %{rates: rates, updated_at: timestamp}
      CurrencyUpdateScheduler.update_state(new_state, pid)

      # Fetch the state
      state = CurrencyUpdateScheduler.get_state(pid)

      # Assert that the fetched state matches the updated rates
      assert state.rates === rates
      assert state.updated_at === timestamp
    end
  end
end
