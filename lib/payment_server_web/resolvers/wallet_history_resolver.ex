defmodule PaymentServerWeb.Resolvers.WalletHistoryResolver do
  alias PaymentServer.Services.WalletHistory

  def create_wallet_history(_, %{input: input}, %{context: %{current_user: current_user}}) do
    WalletHistory.create_wallet_history(input, current_user)
  end

  def get_wallet_history(_, %{id: id}, %{context: %{current_user: current_user}}) do
    WalletHistory.get_wallet_history(id, current_user)
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
