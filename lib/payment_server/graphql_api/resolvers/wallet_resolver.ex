defmodule PaymentServer.GraphqlApi.Resolvers.WalletResolver do

  alias PaymentServer.Wallets
  alias PaymentServer.Accounts

  defp fetch_wallet_for_a_sepecific_user(wallet_id, user_id) do
    case Wallets.get_by_id(wallet_id) do
      nil -> {:error, message: "No wallet found."}

      wallet -> if wallet.user.id === user_id do
        {:ok, wallet}
      else
        {:error, message: "No wallet found."}
      end
    end
  end

  def create_wallet(_, %{input: input}, %{context: %{current_user: current_user}}) do
    Map.update(input, :user_id, current_user.id, fn val -> val end)
      |> Wallets.create([])
      |> case do
        {:ok, wallet} -> {:ok, wallet}
        {:error, changeset} -> {:error, message: "Wallet creation failed!", details: Utils.GraphqlErrorHandler.errors_on(changeset)}
      end
  end

  def get_wallet(_,%{id: id}, %{context: %{current_user: current_user}}) do
    String.to_integer(id)
      |> fetch_wallet_for_a_sepecific_user(current_user.id)
  end

  def get_wallets(_, _, %{context: %{current_user: current_user}}) do
    case Wallets.get_all(current_user.id) do
      nil -> {:error, message: "No wallet found."}
      wallet_list -> {:ok, wallet_list}
    end
  end

  def logger(val) do
    IO.inspect(val, label: "val")
    val
  end

  def update_wallet(_,%{input: input}, %{context: %{current_user: current_user}}) do
    String.to_integer(input.id)
      |> fetch_wallet_for_a_sepecific_user(current_user.id)
      |> case do
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

  def process_transaction(_,%{input: input}, %{context: %{current_user: current_user}}) do
    if input.user_id === current_user.id do
      # TODO: convert currency from 1 to the next
      {:error, message: "Wallet update failed!"}
    else
      case Accounts.get_user(input.user_id) do
        nil -> {:error, message: "The user requested does not exist."}

        recipient -> case Enum.find(recipient.curriences, fn currency -> input.wallet_type === currency.type end) do
          nil -> {:error, message: "Recipient has no wallet with matching currency found."}

          recipient_wallet -> case Enum.find(current_user.curriences, fn cu_currency -> input.wallet_type === cu_currency.type end) do
            nil -> {:error, message: "Sender has no wallet with matching currency found."}

            sender_wallet ->
              updated_senders_wallet = %{id: sender_wallet.id, amount: sender_wallet.amount - input.requested_amount}

              case Wallets.update(updated_senders_wallet) do
                {:ok, _sender_result} ->
                  updated_recipient_wallet = %{id: recipient_wallet.id, amount: recipient_wallet.amount + input.requested_amount}
                  case Wallets.update(updated_recipient_wallet) do
                    {:ok, sender_result} -> {:ok, sender_result}

                    {:error, changeset} ->
                      sender_wallet_refund = %{id: sender_wallet.id, amount: sender_wallet.amount - input.requested_amount}
                      case Wallets.update(sender_wallet_refund) do
                        {:ok, _} -> {
                          :error,
                          message: "We were unable to add the requested amount to the user's Wallet",
                          details: Utils.GraphqlErrorHandler.errors_on(changeset)
                        }
                        {:error, changeset} -> {
                          :error,
                          message: "We were unable to add the requested amount to the user's Wallet and unable to refund subtracted amount",
                          details: Utils.GraphqlErrorHandler.errors_on(changeset)
                        }
                      end
                  end

                {:error, changeset} -> {
                  :error,
                  message: "We were unable to add the requested amount to the user's Wallet",
                  details: Utils.GraphqlErrorHandler.errors_on(changeset)
                }
              end
          end
        end
      end
    end
  end

end
