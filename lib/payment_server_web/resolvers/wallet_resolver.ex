defmodule PaymentServerWeb.Resolvers.WalletResolver do
  alias PaymentServer.SchemasPg.Wallets
  alias PaymentServer.Services.WalletService

  def create_wallet(_, %{type: type}, %{context: %{current_user: current_user}}) do
    case Wallets.create(%{user_id: current_user.id, type: type}, preload: :user) do
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

  def get_wallet(_, %{wallet_type: type}, %{context: %{current_user: %{id: id}}}) do
    Wallets.find_wallet(%{user_id: id, type: type}, preload: :user)
  end

  def get_wallet(_, _, _) do
    {:error, message: "Unauthenticated!!!"}
  end

  def get_wallets(args, _, %{context: %{current_user: current_user}}) do
    {:ok, Wallets.get_all(Map.put(args, :user_id, current_user.id))}
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
