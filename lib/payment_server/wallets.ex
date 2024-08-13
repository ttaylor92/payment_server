defmodule PaymentServer.Wallets do
  import Ecto.Query, warn: false

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
      |> case do
        {:error, changeset} -> {:error, changeset}
        {:ok, struct} ->
          wallet = Repo.preload(struct, :user)
          {:ok, wallet}
      end
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
    Currency
      |> Repo.get(params.id)
      |> Currency.changeset(params)
      |> Repo.update()
      |> case do
        {:ok, schema} -> {:ok, Repo.preload(schema, [:user, :transaction])}
        error -> error
      end
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
    Repo.get(Currency, id) |> Repo.preload([:user, :transaction])
  end

  @doc """
  Retrieves all currencies associated with a given user ID from a database.

  Args:
      id (int): The ID of the user.

  Returns:
      list: A list of dictionaries representing the retrieved currencies. Each dictionary contains the following keys:
        user_id (int): The ID of the user associated with the currency.
        type (str): The type of the currency.

  Example:

  Assuming you have a Currency class defined elsewhere:

  all_currencies = get_all(1)
  print(all_currencies)

  # Output (example):
  # [{'user_id': 1, 'type': 'USD'}, {'user_id': 1, 'type': 'GBP'}]

  Notes:
      This function simulates interacting with a database. It does not perform actual database operations.
  """
  def get_all(id) do
    from(w in Currency, where: w.user_id == ^id)
      |> Repo.all()
  end
end
