defmodule PaymentServer.Services.WalletHistory do
  alias PaymentServer.SchemasPg.WalletHistory

  def create_wallet_history(args, current_user) do
    case WalletHistory.create(Map.update(args, :user_id, current_user.id, fn val -> val end)) do
      {:ok, wallet_history} ->
        case WalletHistory.get_by_id(wallet_history.id) do
          nil ->
            {:error,
             message: "Wallet history creation was successful but fetching response failed!"}

          wallet_history ->
            {:ok, wallet_history}
        end

      {:error, changeset} ->
        {:error,
         message: "Wallet history creation failed!",
         details: Utils.GraphqlErrorHandler.errors_on(changeset)}
    end
  end

  def get_wallet_history(id, current_user) do
    case WalletHistory.get_by_id(String.to_integer(id)) do
      nil ->
        {:error, message: "No wallet history found for id: " <> id}

      wallet_history ->
        if wallet_history.user.id === current_user.id do
          {:ok, wallet_history}
        else
          {:error, message: "No wallet history found for id: " <> id}
        end
    end
  end
end
