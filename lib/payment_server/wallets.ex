defmodule PaymentServer.Wallets do

  alias PaymentServer.Repo
  alias PaymentServer.Wallets.Currency

  @doc """
  Creates a new Currency record in the database.

  ## Arguments:
    * params (Map) - A map containing the data for the new currency.

  ## Returns:
    * {:ok, Currency} - If the currency is created successfully.
    * {:error, Currency} - If there are errors during creation.
  """
  def create(params \\ %{}, options \\ []) do
    params
      |> Currency.create_changeset()
      |> Repo.insert(options)
  end

  @doc """
  Updates an existing Currency record in the database.

  ## Arguments:
    * currency (Currency) - The existing Currency struct to update.
    * params (Map) - A map containing the data for the update.

  ## Returns:
    * {:ok, Currency} - If the currency is updated successfully.
    * {:error, Currency} - If there are errors during update.
  """
  def update(params) do
    %Currency{}
      |> Currency.changeset(params)
      |> Repo.update()
  end

  @doc """
  Deletes a Currency record from the database.

  ## Arguments:
    * currency (Currency) - The Currency struct representing the record to delete.

  ## Returns:
    * {:ok} - If the currency is deleted successfully.
    * {:error, reason} - If there's an error during deletion.
  """
  def delete(params) do
    Repo.delete(params)
  end

  @doc """
  Retrieves a Currency record from the database by its ID.

  ## Arguments:
    * id (integer) - The ID of the Currency record to retrieve.

  ## Returns:
    * Currency | nil - The retrieved Currency struct or nil if not found.
  """
  def get_by_id(id) do
    Repo.get(Currency, id) |> Repo.preload(:user)
  end
end
