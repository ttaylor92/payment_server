defmodule PaymentServer.ExternalApiClient do
  use HTTPoison.Base

  @moduledoc """
  A client module for interacting with an external API.
  """

  @api_base_url "http://localhost:4001"

  @doc """
  Fetches a currency by its Currency Code, using USD as the default currency to exchange from.

  ## Parameters

    - `to_currency_code`: The code for the currency to convert to.
    - `from_currency_code`: The code for the currency to convert from, default "USD".

  ## Examples

      iex> MyApp.ExternalApiClient.get_currency("AUD")
      {:ok, %{
        time_zone: "UTC",
        from_currency_code: "USD",
        to_currency_code: "AUD",
        from_currency_name: "US Dollar",
        to_currency_name: "Australian Dollar",
        exchange_rate: "3.33",
        last_refreshed: "2024-07-09 22:25:53.732684Z",
        bid_price: "3.33",
        ask_price: "3.33"
      }}
  """
  def get_currency(to_currency_code, from_currency_code \\ "USD") do
    url = "#{@api_base_url}/query?function=CURRENCY_EXCHANGE_RATE&from_currency=#{from_currency_code}&to_currency=#{to_currency_code}"
    case get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, parsed} -> {:ok, transform_keys(parsed)}
          {:error, reason} -> {:error, reason}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} when status_code in 400..499 ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Transforms the keys of the provided map by removing numerical prefixes,
  replacing spaces with underscores, and converting them to atoms in lowercase.

  ## Parameters

    - `%{"Realtime Currency Exchange Rate" => rate_data}`:
    A map with a key `"Realtime Currency Exchange Rate"` that contains another map `rate_data`.

  ## Returns

    - A map with the keys of `rate_data` transformed as follows:
      - Numerical prefixes followed by a period and space (e.g., `"1. "`) are removed.
      - Spaces are replaced with underscores.
      - Keys are converted to lowercase atoms.

  ## Examples

      iex> transform_keys(
      %{
        "Realtime Currency Exchange Rate" => %{
            "1. From_Currency Code" => "USD",
            "2. From_Currency Name" => "United States Dollar"
          }
        }
      )
      %{from_currency_code: "USD", from_currency_name: "United States Dollar"}

  """
  def transform_keys(%{"Realtime Currency Exchange Rate" => rate_data}) do
    rate_data
      |> Enum.map(fn {key, value} ->
        new_key = key
          |> String.replace(~r/^\d+\. /, "")
          |> String.replace(~r/\s/, "_")
          |> String.downcase()
        {String.to_atom(new_key), value}
      end)
      |> Enum.into(%{})
  end
end
