defmodule PaymentServer.GraphqlApi.Resolvers.WalletResolver do
  alias PaymentServer.Wallets
  alias PaymentServer.Accounts
  alias NimbleCSV.RFC4180, as: CSV

  defp fetch_accepted_currencies() do
    root_dir = Mix.Project.app_path()
    file_path = Path.join([root_dir, "priv", "data", "physical_currency_list.csv"])

    file_path
      |> File.stream!()
      |> CSV.parse_stream()
      |> Enum.map(fn [column1, column2] ->
          %{
            value: column1,
            label: column2
          }
        end)
  end

  defp get_user(user_id) do
    case Accounts.get_user(user_id) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  defp find_wallet(user, wallet_type) do
    case Enum.find(user.curriences, fn currency -> wallet_type === currency.type end) do
      nil -> {:error, :wallet_not_found}
      wallet -> {:ok, wallet}
    end
  end

  defp update_wallet(wallet, amount_change) do
    updated_wallet = %{wallet | amount: wallet.amount + amount_change}
    case Wallets.update(updated_wallet) do
      {:ok, result} -> {:ok, result}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp get_exchange_rate(currency_to, currency_from) do
    case PaymentServer.ExternalApiClient.get_currency(currency_to, currency_from) do
      {:ok, result} -> {:ok, String.to_float(result.exchange_rate)}
      {:error, _} -> {:error, :exchange_rate_not_found}
    end
  end

  defp convert_wallet(wallet, exchange_rate, new_currency_type) do
    new_wallet_amount = wallet.amount * exchange_rate
    updated_wallet = %{id: wallet.id, amount: new_wallet_amount, type: new_currency_type}
    {:ok, updated_wallet}
  end

  def create_wallet(_, %{input: input}, %{context: %{current_user: current_user}}) do
    Map.update(input, :user_id, current_user.id, fn val -> val end)
      |> Wallets.create([])
      |> case do
        {:ok, wallet} -> {:ok, wallet}
        {:error, changeset} ->
          {:error,
            message: "Wallet creation failed!",
            details: Utils.GraphqlErrorHandler.errors_on(changeset)
          }
      end
  end

  def get_currencies(_, _, %{context: %{current_user: _current_user}}) do
    {:ok, fetch_accepted_currencies()}
  end

  def get_wallet(_,%{id: id}, %{context: %{current_user: current_user}}) do
    find_wallet(current_user, String.to_integer(id))
  end

  def get_wallets(_, _, %{context: %{current_user: current_user}}) do
    case Wallets.get_all(current_user.id) do
      nil -> {:error, message: "No wallet found."}
      wallet_list -> {:ok, wallet_list}
    end
  end

  def update_wallet(_,%{input: input}, %{context: %{current_user: current_user}}) do
    case find_wallet(current_user, String.to_integer(input.id)) do
      {:error, message} -> {:error, message}
      {:ok, wallet} -> %{input | id: String.to_integer(input.id)}
        |> Map.put(:user_id, current_user.id)
        |> Map.put(:type, wallet.type)
        |> Wallets.update()
        |> case do
          {:ok, result} -> {:ok, result}
          {:error, changeset} -> {
            :error,
            message: "Wallet update failed!",
            details: Utils.GraphqlErrorHandler.errors_on(changeset)
          }
        end
    end
  end

  def delete_wallet(_,%{id: id}, %{context: %{current_user: current_user}}) do
    case Wallets.get_by_id(String.to_integer(id)) do
      nil -> {:error, message: "Wallet was not found."}

      wallet -> if wallet.user_id === current_user.id do
        case Wallets.delete(wallet) do
          {:ok} -> {:ok, message: "Wallet deleted."}
          {:error, changeset} -> {
            :error,
            message: "Wallet update failed!",
            details: Utils.GraphqlErrorHandler.errors_on(changeset)
          }
          end
        else
          {:error, message: "You do not have permissions to update this wallet."}
        end
    end
  end

  def process_transaction(_, %{input: input}, %{context: %{current_user: current_user}}) do
    with {:ok, recipient} <- get_user(input.user_id),
        {:ok, recipient_wallet} <- find_wallet(recipient, input.wallet_type),
        {:ok, sender_wallet} <- find_wallet(current_user, input.wallet_type),
        {:ok, _sender_result} <- update_wallet(sender_wallet, -input.requested_amount),
        {:ok, sender_result} <- update_wallet(recipient_wallet, input.requested_amount) do
      {:ok, sender_result}
    else
      {:error, :user_not_found} ->
        {:error, message: "The user requested does not exist."}

      {:error, :wallet_not_found} ->
        {:error, message: "Recipient or sender has no wallet with matching currency found."}

      {:error, changeset} ->
        {:error,
          message: "Transaction failed.",
          details: Utils.GraphqlErrorHandler.errors_on(changeset)
        }
    end
  end

  def process_wallet_conversion(_, %{input: input}, %{context: %{current_user: current_user}}) do
    with {:ok, exchange_rate} <- get_exchange_rate(input.currency_to, input.currency_from),
        {:ok, wallet_to_convert} <- find_wallet(current_user, input.currency_from),
        {:ok, updated_wallet} <- convert_wallet(wallet_to_convert, exchange_rate, input.currency_to),
        {:ok, data} <- Wallets.update(updated_wallet) do
      {:ok, data}
    else
      {:error, :exchange_rate_not_found} ->
        {:error, message: "Failed to retrieve exchange rate."}

      {:error, :wallet_not_found} ->
        {:error, message: "Requested wallet to convert does not exist."}

      {:error, changeset} ->
        {:error,
          message: "We were unable to convert your #{input.currency_from} wallet to #{input.currency_to}",
          details: Utils.GraphqlErrorHandler.errors_on(changeset)
        }
    end
  end

  def get_total_worth(_, %{currency: currency}, %{context: %{current_user: current_user}}) do
    # TODO:
  end
end
