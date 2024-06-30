defmodule PaymentServer.WalletHistory.WalletHistory do

  import Ecto.Query, warn: false
  alias PaymentServer.Repo

  alias PaymentServer.WalletHistory.TransactionHistory

  @doc """
  Creates a new WalletHistory record in the database.

  This function utilizes the `TransactionHistory.changeset/1` function to validate and format the provided data before persisting it to the database.

  ## Arguments:
    * params (Map) - A map containing the data for the new wallet history entry. Expected keys include:
      * type (String) - The type of transaction (e.g., "deposit", "withdrawal")
      * amount (Decimal) - The transaction amount.
      * currency (Currency) - The currency/wallet related to transaction.
      * user_id (Integer) - The ID of the user associated with the transaction.

  ## Returns:
    * {:ok, WalletHistory} - If the wallet history is created successfully.
    * {:error, reason} - If there are errors during creation, including validation errors.
  """
  def create(params) do
    %TransactionHistory{}
      |> TransactionHistory.changeset(params)
      |> Repo.insert()
  end

  @doc """
  Updates an existing WalletHistory record in the database.

  This function retrieves the existing WalletHistory record, applies the provided data for update, and validates it using `TransactionHistory.changeset/1` before persisting the changes.

  ## Arguments:
    * wallet_history (WalletHistory) - The existing WalletHistory struct to update.
    * params (Map) - A map containing the data for the update. Expected keys include the same as `create/1`.

  ## Returns:
    * {:ok, WalletHistory} - If the wallet history is updated successfully.
    * {:error, reason} - If there are errors during update, including validation errors.
  """
  def update(wallet_history, params) do
    wallet_history
      |> TransactionHistory.changeset(params)
      |> Repo.update()
  end

  @doc """
  Deletes a WalletHistory record from the database.

  This function directly deletes the provided WalletHistory record.

  ## Arguments:
    * wallet_history (WalletHistory) - The WalletHistory struct representing the record to delete.

  ## Returns:
    * {:ok} - If the wallet history is deleted successfully.
    * {:error, reason} - If there's an error during deletion.
  """
  def delete(wallet_history) do
    Repo.delete(wallet_history)
  end

  @doc """
  Retrieves a WalletHistory record from the database by its ID.

  This function retrieves a single WalletHistory record from the database based on the provided ID.

  ## Arguments:
    * id (integer) - The ID of the WalletHistory record to retrieve.

  ## Returns:
    * WalletHistory | nil - The retrieved WalletHistory struct or nil if no record is found with the given ID.
  """
  def get_by_id(id) do
    Repo.get(WalletHistorySchema, id)
  end
end
