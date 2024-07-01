defmodule PaymentServer.GraphqlApi.Resolvers.WalletResolver do

  alias PaymentServer.Wallets

  def create_wallet(_, %{input: input}, %{context: %{current_user: current_user}}) do
    Map.update(input, :user_id, current_user.id, fn val -> val end)
      |> Wallets.create([])
      |> case do
        {:ok, wallet} -> {:ok, wallet}
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

  def get_wallets(_, _, %{context: %{current_user: current_user}}) do
    case Wallets.get_all(current_user.id) do
      nil -> {:error, message: "No wallet found."}
      wallet_list -> {:ok, wallet_list}
    end
  end

  def update_wallet(_,%{input: input}, %{context: %{current_user: current_user}}) do
    if input.user_id === current_user.id do
      case Wallets.update(input) do
        {:ok, result} -> {:ok, result}
        {:error, changeset} -> {:error, message: "Wallet update failed!", details: Utils.GraphqlErrorHandler.errors_on(changeset)}
      end
    else
      {:error, message: "You do not have permissions to update this wallet."}
    end
  end

  def delete_wallet(_,%{id: id}, %{context: %{current_user: current_user}}) do
    case Wallets.get_by_id(String.to_integer(id)) do
      nil -> {:error, message: "Wallet was not found."}

      wallet -> if wallet.user_id === current_user.id do
        case Wallets.delete(wallet) do
          {:ok} -> {:ok, message: "Wallet deleted."}
          {:error, changeset} -> {:error, message: "Wallet update failed!", details: Utils.GraphqlErrorHandler.errors_on(changeset)}
          end
        else
          {:error, message: "You do not have permissions to update this wallet."}
        end
    end
  end

end
