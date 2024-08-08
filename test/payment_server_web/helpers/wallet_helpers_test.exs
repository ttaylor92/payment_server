defmodule PaymentServerWeb.WalletHelpersTest do
  use ExUnit.Case

  alias PaymentServerWeb.WalletHelpers

  describe "fetch_accepted_currencies/0" do
    test "parses CSV file correctly" do
      result = WalletHelpers.fetch_accepted_currencies()
      expected_result = %{value: "AED", label: "United Arab Emirates Dirham"}

      assert List.first(result) == expected_result
    end
  end
end
