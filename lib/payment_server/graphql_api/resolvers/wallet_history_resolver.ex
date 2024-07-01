defmodule PaymentServer.GraphqlApi.Resolvers.WalletHistoryResolver do

  alias PaymentServer.WalletHistory

  def create_wallet_history(_, %{input: input}, %{context: %{current_user: current_user}}) do
    Map.update(input, :user_id, current_user.id, fn val -> val end)
      |> WalletHistory.create([])
      |> case do
        {:ok, wallet_history} -> case WalletHistory.get_by_id(wallet_history.id) do
          nil -> {:error, message: "Wallet history creation was successful but fetching response failed!"}
          wallet_history -> {:ok, wallet_history}
        end
        {:error, changeset} -> {:error, message: "Wallet history creation failed!", details: Utils.GraphqlErrorHandler.errors_on(changeset)}
      end
  end

  def get_wallet_history(_, %{id: id}, %{context: %{current_user: current_user}}) do
    case WalletHistory.get_by_id(String.to_integer(id)) do
      nil -> {:error, message: "No wallet history found for id: " <> id}
      wallet_history -> if wallet_history.user.id === current_user.id do
        {:ok, wallet_history}
      else
        {:error, message: "No wallet history found for id: " <> id}
      end
    end
  end

  # def get_a_wallets_history(_, %{id: id}, %{context: %{current_user: current_user}}) do
  #   case Wallets.get_by_id(String.to_integer(id)) do
  #     nil -> {:error, message: "No wallet history found for wallet with id: " <> id}
  #     wallet -> if wallet.user.id === current_user.id do
  #       updated_wallet = Map.put(wallet, :transaction_history, WalletHistory.get_by_wallet_id(wallet.id))
  #       {:ok, wallet: updated_wallet}
  #     else
  #       {:error, message: "No wallet history found for wallet with id: " <> id}
  #     end
  #   end
  # end
end
