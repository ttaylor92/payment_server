defmodule PaymentServer.GraphqlApi.Resolvers.WalletResolver do

  alias PaymentServer.Wallets

  def create_wallet(_, %{input: input}, %{context: %{current_user: current_user}}) do
    Map.update(input, :user_id, current_user.id, fn val -> val end)
      |> Wallets.create([])
      |> case do
        {:ok, wallet} -> {:ok, wallet: Wallets.get_by_id(wallet.id)}
        {:error, changeset} -> {:error, message: "Wallet creation failed!", details: Utils.GraphqlErrorHandler.errors_on(changeset)}
      end
  end

  def get_wallet(_,%{id: id}, %{context: %{current_user: current_user}}) do
    case Wallets.get_by_id(String.to_integer(id)) do
      nil -> {:error, message: "No wallet found."}
      wallet -> if wallet.user.id === current_user.id do
        {:ok, wallet}
      else
        {:error, message: "No wallet found."}
      end
    end
  end
end
