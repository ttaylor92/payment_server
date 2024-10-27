defmodule PaymentServer.ExternalApiClientTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServer.ExternalApiClient

  describe "transform_keys/1" do
    test "returns map with formatted keys as atoms in snake case" do
      map_example = %{
        "Realtime Currency Exchange Rate" => %{
          "1. From_Currency Code" => "USD",
          "2. From_Currency Name" => "United States Dollar"
        }
      }

      parsed_map = ExternalApiClient.transform_keys(map_example)
      assert parsed_map.from_currency_code === "USD"
    end
  end
end
