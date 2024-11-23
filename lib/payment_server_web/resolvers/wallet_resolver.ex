defmodule PaymentServerWeb.Resolvers.WalletResolver do
  alias PaymentServer.SchemasPg.Accounts.User
  alias PaymentServer.SchemasPg.Accounts
  alias PaymentServer.SchemasPg.Wallets
  alias PaymentServer.Services.WalletService

  def create_wallet(_, %{type: type}, %{context: %{current_user: current_user}}) do
    case Wallets.create(%{user_id: current_user.id, type: type}, []) do
      {:ok, wallet} ->
        {:ok, wallet}

      {:error, changeset} ->
        {:error,
         message: "Wallet creation failed!",
         details: Utils.GraphqlErrorHandler.errors_on(changeset)
        }
    end
  end

  def create_wallet(_, _, _) do
    {:error, message: "Unauthenticated!!!"}
  end

  def get_currencies(_, _, %{context: %{current_user: _current_user}}) do
    {:ok, WalletService.fetch_accepted_currencies()}
  end

  def get_currencies(_, _, _) do
    {:error, message: "Unauthenticated!!!"}
  end

  def get_wallet(_, %{wallet_type: wallet_type}, %{context: %{current_user: current_user}}) do
    with {:ok, user} <- Accounts.get_user(current_user.id, preload: :curriences) do
      case WalletService.find_wallet(user, wallet_type) do
        {:error, _} -> {:error, message: "Wallet not found!"}

        {:ok, wallet} ->
          case Wallets.get_by_id(wallet.id) do
            nil -> {:error, message: "Wallet not found!"}
            wallet -> {:ok, wallet}
          end
      end
    end
  end

  def get_wallet(_, _, _) do
    {:error, message: "Unauthenticated!!!"}
  end

  def get_wallets(_, _, %{context: %{current_user: current_user}}) do
    case Wallets.get_all(current_user.id) do
      nil -> {:error, message: "No wallet found."}
      wallet_list -> {:ok, wallet_list}
    end
  end

  def get_wallets(_, _, _) do
    {:error, message: "Unauthenticated!!!"}
  end

  def update_wallet(_, %{input: input}, %{context: %{current_user: current_user}}) do
    WalletService.update_wallet(input, current_user)
  end

  def update_wallet(_, _, _) do
    {:error, message: "Unauthenticated!!!"}
  end

  def delete_wallet(_, %{id: id}, %{context: %{current_user: current_user}}) do
    WalletService.delete_wallet(id, current_user)
  end

  def delete_wallet(_, _, _) do
    {:error, message: "Unauthenticated!!!"}
  end

  def process_transaction(_, %{input: input}, %{context: %{current_user: current_user}}) do
    WalletService.process_transaction(input, current_user)
  end

  def process_transaction(_, _, _) do
    {:error, message: "Unauthenticated!!!"}
  end

  def process_wallet_conversion(_, %{input: input}, %{context: %{current_user: current_user}}) do
    WalletService.process_wallet_conversion(input, current_user)
  end

  def process_wallet_conversion(_, _, _) do
    {:error, message: "Unauthenticated!!!"}
  end
end
