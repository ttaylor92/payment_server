defmodule PaymentServer.WalletService do
  alias PaymentServer.CurrencyUpdateScheduler
  alias PaymentServer.SchemasPg.Wallets
  alias PaymentServer.SchemasPg.Accounts
  alias PaymentServer.CurrencyExchangeApi
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
  def get_user(user_id) do
    case Accounts.get_user(user_id, preload: :curriences) do
      {:error, _} -> {:error, :user_not_found}
      {:ok, user} -> {:ok, user}
    end
  end

  @doc """
  Fetches the exchange rate between two currencies.
  """
  def get_exchange_rate(currency_to, currency_from, display_error?, api_client \\ CurrencyExchangeApi)

  def get_exchange_rate(currency_to, currency_from, display_error?, api_client) do
    case find_rate_by_currency(currency_to) do
      nil ->
        fetch_and_create_exchange_rate(currency_to, currency_from, display_error?, api_client)

      rate ->
        if time_beyond_limit?(rate.inserted_at, 10) === false do
          if display_error? do
            {:ok, rate}
          else
            %{currency_to: currency_to, currency_from: currency_from, rate: rate.value}
          end
        else
          fetch_and_create_exchange_rate(currency_to, currency_from, display_error?, api_client)
        end
    end
  end

  defp fetch_and_create_exchange_rate(currency_to, currency_from, display_error?, api_client) do
    case api_client.get_currency(currency_to, currency_from) do
      {:ok, result} ->
        exchange_rate = String.to_float(result["exchange_rate"])
        rate_request = %{currency_to: currency_to, currency_from: currency_from, rate: exchange_rate}

        if display_error? do
          {:ok, exchange_rate}
        else
          rate_request
        end

      {:error, _} ->
        if display_error? do
          {:error, :exchange_rate_not_found}
        else
          %{currency_from: currency_from, currency_to: currency_to, rate: 0}
        end
    end
  end

  defp fetch_exchange_and_returned_converted_value(wallet, currency_to, api_client) do
    if wallet.type === currency_to do
      wallet.amount
    else
      case get_exchange_rate(currency_to, wallet.type, true, api_client) do
        {:ok, _rate} when is_nil(wallet.amount) -> 0
        {:ok, rate} -> wallet.amount * rate
        {:error, _} -> 0
      end
    end
  end

  defp time_beyond_limit?(inserted_time, time) do
    DateTime.diff(DateTime.utc_now(), inserted_time, :minute) >= time
  end

  defp find_rate_by_currency(currency_to) do
    cache = CurrencyUpdateScheduler.get_state()
    Enum.find(cache.rates, nil, fn rate -> rate.currency_to === currency_to end)
  end

  @doc """
  Gets the total worth of a user's wallets in their default currency.
  """
  def get_total_worth(
        user_id,
        api_client \\ CurrencyExchangeApi
      ) do
    case get_user(user_id) do
      {:ok, %PaymentServer.SchemasPg.Accounts.User{} = user} ->
        result = user.curriences
        |> Task.async_stream(
          &fetch_exchange_and_returned_converted_value(&1, user.default_currency, api_client),
          max_concurrency: 10,
          timeout: 5000
        )
        |> Enum.reduce({:ok, 0}, fn
          {:ok, converted_value}, {:ok, acc} when is_number(converted_value) ->
            {:ok, acc + converted_value}

          {:error, _} = error, {:ok, _acc} ->
            error

          _other, {:ok, _acc} ->
            {:error, message: "Unexpected result format!"}
        end)

        case result do
          {:ok, value} ->
            Absinthe.Subscription.publish(
              PaymentServerWeb.Endpoint,
              %{amount: value, default_currency: user.default_currency},
              total_worth_update: user_id
            )

          {:error, message} ->
            {:error, message}
        end

      {:error, _reason} ->
        {:error, message: "User does not exist."}
    end
  end

  @doc """
  Publishes a currency update.
  """
  def get_currency_update(
        currency_to,
        default_currency \\ "USD",
        api_client \\ CurrencyExchangeApi
      ) do
    topic = "currency:#{currency_to}"

    case get_exchange_rate(currency_to, default_currency, true, api_client) do
      {:ok, value} ->
        Absinthe.Subscription.publish(
          PaymentServerWeb.Endpoint,
          %{amount: value, default_currency: default_currency},
          currency_update: topic
        )

      {:error, _} ->
        {:error, message: "Unable to fetch update for: #{currency_to}"}
    end
  end

  @doc """
  Publishes updates for all currencies.
  """
  def get_all_currency_updates(cached_accepted_currencies, file_reader \\ &File.read!/1, csv_parser \\ &CSV.parse_string/1) do
    accepted_currencies = fetch_accepted_currencies(file_reader, csv_parser)

    if Enum.empty?(cached_accepted_currencies.rates) or time_beyond_limit?(cached_accepted_currencies.updated_at, 2) do
      fetch_exchange_rate_and_publish(accepted_currencies)
    else
      publish_db_list_of_currencies(cached_accepted_currencies)
    end
  end

  defp fetch_exchange_rate_and_publish(
    accepted_currencies,
    default_currency \\ "USD",
    api_client \\ CurrencyExchangeApi
  ) do
    results = accepted_currencies
      |> Task.async_stream(
        &fetch_and_create_exchange_rate(&1.value, default_currency, false, api_client),
        max_concurrency: 10,
        timeout: 5000
      )
      |> Enum.reduce([], fn
        {:ok, result}, acc -> [result | acc]
        {:error, _reason}, acc -> acc
      end)
      |> Enum.map(fn currency ->
        if is_float(currency.rate) do
          currency
        else
          Map.update(currency, :rate, 0.0, fn val -> val / 1 end)
        end
      end)

    Absinthe.Subscription.publish(
      PaymentServerWeb.Endpoint,
      results,
      all_currencies_update: "all_currencies"
    )

    Enum.each(results, fn result ->
      Task.start(fn ->
        topic = "currency:#{result.currency_to}"

        Absinthe.Subscription.publish(
          PaymentServerWeb.Endpoint,
          %{amount: result.rate, default_currency: default_currency},
          currency_update: topic
        )
      end)
    end)

    update_cache(results)
  end

  defp publish_db_list_of_currencies(db_list_of_currencies) do
    results = Enum.map(db_list_of_currencies.rates, fn currency ->
      %{currency_from: currency.currency_from, currency_to: currency.currency_to, rate: currency.rate}
    end)

    Absinthe.Subscription.publish(
      PaymentServerWeb.Endpoint,
      results,
      all_currencies_update: "all_currencies"
    )

    Enum.each(results, fn result ->
      Task.start(fn ->
        topic = "currency:#{result.currency_to}"

        Absinthe.Subscription.publish(
          PaymentServerWeb.Endpoint,
          %{amount: result.rate, default_currency: result.currency_from},
          currency_update: topic
        )
      end)
    end)

    # Return map of data
    db_list_of_currencies
  end

  defp update_cache(results) do
    timestamp = DateTime.utc_now()
    %{rates: results, updated_at: timestamp}
  end

  def find_wallet(user, id) when is_number(id) do
    case Enum.find(user.curriences, fn currency -> id === currency.id end) do
      nil -> {:error, :wallet_not_found}
      wallet -> {:ok, wallet}
    end
  end

  def find_wallet(user, wallet_type) do
    case Enum.find(user.curriences, fn currency -> wallet_type === currency.type end) do
      nil -> {:error, :wallet_not_found}
      wallet -> {:ok, wallet}
    end
  end

  def convert_wallet(wallet, exchange_rate, new_currency_type) do
    new_wallet_amount = wallet.amount * exchange_rate
    updated_wallet = %{id: wallet.id, amount: new_wallet_amount, type: new_currency_type}
    {:ok, updated_wallet}
  end

  def update_wallet(wallet, amount_change) when is_float(amount_change) do
    case Wallets.update(wallet, %{amount: wallet.amount + amount_change}, preload: [:user]) do
      {:ok, result} -> {:ok, result}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_wallet(args, current_user) do
    with {:ok, user} <- get_user(current_user.id) do
      case find_wallet(user, String.to_integer(args.id)) do
        {:error, _} ->
          {:error, message: "Wallet not found!"}

        {:ok, wallet} ->
          attrs =
            %{args | id: String.to_integer(args.id)}
            |> Map.put(:user_id, current_user.id)
            |> Map.put(:type, wallet.type)


          case Wallets.update(wallet, attrs, preload: [:user]) do
            {:ok, result} ->
              {:ok, result}

            {:error, changeset} ->
              {
                :error,
                message: "Wallet update failed!",
                details: Utils.GraphqlErrorHandler.errors_on(changeset)
              }
          end
      end
    end
  end

  def delete_wallet(id, current_user) do
    case find_wallet(current_user, String.to_integer(id)) do
      {:error, _} ->
        {:error, message: "Wallet was not found."}

      {:ok, wallet} ->
        case Wallets.delete(wallet) do
          {:ok, _result} ->
            {:ok, %{message: "Wallet deleted."}}

          {:error, changeset} ->
            {
              :error,
              message: "Wallet update failed!",
              details: Utils.GraphqlErrorHandler.errors_on(changeset)
            }
        end
    end
  end

  def process_transaction(args, current_user) do
    with {:ok, recipient} <- get_user(args.user_id),
        {:ok, recipient_wallet} <- find_wallet(recipient, args.wallet_type),
        {:ok, sender} <- get_user(current_user.id),
        {:ok, sender_wallet} <- find_wallet(sender, args.wallet_type),
        {:ok, sender_result} <- update_wallet(sender_wallet, -args.requested_amount),
        {:ok, _recipient_result} <- update_wallet(recipient_wallet, args.requested_amount) do
      get_total_worth(current_user.id)
      get_total_worth(recipient.id)
      {:ok, sender_result}
    else
      {:error, :user_not_found} ->
        {:error, message: "The user requested does not exist."}

      {:error, :wallet_not_found} ->
        {:error, message: "Recipient or sender has no wallet with matching currency found."}

      {:error, changeset} ->
        {:error,
         message: "Transaction failed.", details: Utils.GraphqlErrorHandler.errors_on(changeset)}
    end
  end

  def process_wallet_conversion(args, current_user) do
    with {:ok, exchange_rate} <- get_exchange_rate(args.currency_to, args.currency_from, true),
        {:ok, wallet_to_convert} <- find_wallet(current_user, args.currency_from),
        {:ok, updated_wallet} <-
          convert_wallet(wallet_to_convert, exchange_rate, args.currency_to),
        {:ok, data} <- Wallets.update(wallet_to_convert, updated_wallet, preload: [:user]) do
    {:ok, data}
    else
    {:error, :exchange_rate_not_found} ->
      {:error, message: "Failed to retrieve exchange rate."}

    {:error, :wallet_not_found} ->
      {:error, message: "Requested wallet to convert does not exist."}

    {:error, changeset} ->
      {:error,
        message:
          "We were unable to convert your #{args.currency_from} wallet to #{args.currency_to}",
        details: Utils.GraphqlErrorHandler.errors_on(changeset)}
    end
  end
end
