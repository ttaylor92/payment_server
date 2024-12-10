defmodule PaymentServer.WalletServiceTest do
  use ExUnit.Case

  alias PaymentServer.WalletService

  describe "fetch_accepted_currencies/0" do
    test "parses CSV file correctly" do
      result = WalletService.fetch_accepted_currencies()
      expected_result = %{value: "AED", label: "United Arab Emirates Dirham"}

      assert List.first(result) === expected_result
    end
  end
end
