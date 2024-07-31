defmodule PaymentServerWeb.WalletHelpers do
  alias PaymentServer.Accounts
  alias NimbleCSV.RFC4180, as: CSV

  @doc """
  Fetches the accepted currencies from the CSV file.
  """
  def fetch_accepted_currencies(file_reader \\ &File.read!/1, csv_parser \\ &CSV.parse_string/1) do
    root_dir = Mix.Project.app_path()
    file_path = Path.join([root_dir, "priv", "data", "physical_currency_list.csv"])

    file_content = file_reader.(file_path)
    file_content
    |> csv_parser.()
    |> Enum.map(fn [column1, column2] ->
      %{
        value: column1,
        label: column2
      }
    end)
  end

  @doc """
  Gets a user by user_id.
  """
  def get_user(user_id, accounts \\ Accounts) do
    case accounts.get_user(user_id) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  @doc """
  Fetches the exchange rate between two currencies.
  """
  def get_exchange_rate(currency_to, currency_from, api_client \\ PaymentServer.ExternalApiClient, display_error)

  def get_exchange_rate(currency_to, currency_from, api_client, true) do
    case api_client.get_currency(currency_to, currency_from) do
      {:ok, result} -> {:ok, String.to_float(result.exchange_rate)}
      {:error, _} -> {:error, :exchange_rate_not_found}
    end
  end

  def get_exchange_rate(currency_to, currency_from, api_client, false) do
    case api_client.get_currency(currency_to, currency_from) do
      {:ok, result} -> %{currency_from: currency_from, currency_to: currency_to, rate: String.to_float(result.exchange_rate)}
      {:error, _} -> %{currency_from: currency_from, currency_to: currency_to, rate: 0}
    end
  end

  defp fetch_exchange_and_returned_converted_value(wallet, currency_to, api_client) do
    if wallet.type == currency_to do
      {:ok, wallet.amount}
    else
      case get_exchange_rate(currency_to, wallet.type, api_client) do
        {:ok, _rate} when is_nil(wallet.amount) -> 0
        {:ok, rate} -> wallet.amount * rate
        {:error, _} -> {:error, message: "Unable to retrieve exchange rate for #{currency_to}"}
      end
    end
  end

  @doc """
  Gets the total worth of a user's wallets in their default currency.
  """
  def get_total_worth(user_id, accounts \\ Accounts, api_client) do
    case get_user(user_id, accounts) do
      {:ok, %PaymentServer.Accounts.User{} = user} ->
        result = user.curriences
        |> Task.async_stream(
          &fetch_exchange_and_returned_converted_value(&1, user.default_currency, api_client),
          max_concurrency: 10,
          timeout: 5000
        )
        |> Enum.reduce({:ok, 0}, fn
          {:ok, converted_value}, {:ok, acc} when is_number(converted_value) ->
            {:ok, acc + converted_value}
          {:error, _} = error, {:ok, _acc} -> error
          _other, {:ok, _acc} ->
            {:error, message: "Unexpected result format!"}
        end)

        case result do
          {:ok, value} -> Absinthe.Subscription.publish(
              PaymentServerWeb.Endpoint, %{amount: value, default_currency: user.default_currency}, total_worth_update: user_id
            )
          {:error, message} -> {:error, message}
        end
      {:error, _reason} -> {:error, message: "User does not exist."}
    end
  end

  @doc """
  Publishes a currency update for a user.
  """
  def get_currency_update(user_id, currency_to, accounts \\ Accounts, api_client \\ PaymentServer.ExternalApiClient) do
    case get_user(user_id, accounts) do
      {:ok, %PaymentServer.Accounts.User{} = user} ->
        case get_exchange_rate(currency_to, user.default_currency, api_client) do
          {:ok, value} -> Absinthe.Subscription.publish(
              PaymentServerWeb.Endpoint, %{amount: value, default_currency: user.default_currency}, currency_update: currency_to
            )
          {:error, _} -> {:error, message: "Unable to fetch update for: #{currency_to}"}
        end
      {:error, _reason} -> {:error, message: "User does not exist."}
    end
  end

  @doc """
  Publishes updates for all currencies for a user.
  """
  def get_all_currency_updates(
    user_id,
    accounts \\ Accounts,
    api_client \\ PaymentServer.ExternalApiClient,
    file_reader \\ &File.read!/1,
    csv_parser \\ &CSV.parse_string/1
    ) do
    case get_user(user_id, accounts) do
      {:ok, %PaymentServer.Accounts.User{} = user} ->
        results = fetch_accepted_currencies(file_reader, csv_parser)
        |> Task.async_stream(
          &get_exchange_rate(&1.value, user.default_currency, api_client, :no_error),
          max_concurrency: 10,
          timeout: 5000
        )
        |> Enum.reduce([], fn
          {:ok, result}, acc -> [result | acc]
          {:error, _reason}, acc -> acc
        end)

        Absinthe.Subscription.publish(
          PaymentServerWeb.Endpoint, results, all_currencies_update: "all_currencies"
        )
      {:error, _reason} -> {:error, message: "User does not exist."}
    end
  end
end
