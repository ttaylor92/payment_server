defmodule PaymentServer.Wallets.Helpers do
  alias PaymentServer.Accounts

  def get_user(user_id) do
    case Accounts.get_user(user_id) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  def get_exchange_rate(currency_to, currency_from) do
    case PaymentServer.ExternalApiClient.get_currency(currency_to, currency_from) do
      {:ok, result} -> {:ok, String.to_float(result.exchange_rate)}
      {:error, _} -> {:error, :exchange_rate_not_found}
    end
  end

  defp fetch_exchange_and_returned_converted_value(wallet, currency_to) do
    if wallet.type === currency_to do
      {:ok, wallet.amount}
    else
      case get_exchange_rate(currency_to, wallet.type) do
        {:ok, _rate} when is_nil(wallet.amount) -> 0
        {:ok, rate} -> wallet.amount * rate
        {:error, _} -> {:error, message: "Unable to retreive exhange rate for #{currency_to}"}
      end
    end
  end

  def get_total_worth(user_id) do
    case get_user(user_id) do
      {:ok, %PaymentServer.Accounts.User{} = user} ->
        result = user.curriences
          |> Task.async_stream(
              &fetch_exchange_and_returned_converted_value(&1, user.default_currency),
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
          {:ok, value} -> Absinthe.Subscription.publish(PaymentServerWeb.Endpoint, %{amount: value}, total_worth_update: user_id)
          {:error, message} -> {:error, message}
        end
      {:error, _reason} -> {:error, message: "User does not exist."}
    end
  end

  def get_currency_update(user_id, currency_to) do
    case get_user(user_id) do
      {:ok, %PaymentServer.Accounts.User{} = user} ->
        case get_exchange_rate(currency_to, user.default_currency) do
          {:ok, value} -> Absinthe.Subscription.publish(PaymentServerWeb.Endpoint, %{amount: value}, currency_update: user_id)
          {:error, _} -> {:error, message: "Unable to fetch update for: #{currency_to}"}
        end
      {:error, _reason} -> {:error, message: "User does not exist."}
    end
  end
end
