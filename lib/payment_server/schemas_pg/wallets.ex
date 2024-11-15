defmodule PaymentServer.SchemasPg.Wallets do
  import Ecto.Query, warn: false

  alias PaymentServer.Repo
  alias PaymentServer.SchemasPg.Wallets.Currency

  def create(params \\ %{}, options \\ []) do
    params
    |> Currency.create_changeset()
    |> Repo.insert(options)
    |> case do
      {:error, changeset} ->
        {:error, changeset}

      {:ok, struct} ->
        wallet = Repo.preload(struct, :user)
        {:ok, wallet}
    end
  end

  def update(%Currency{} = changeset, params) do
    changeset
    |> Currency.update_changeset(params)
    |> Repo.update()
    |> case do
      {:ok, schema} -> {:ok, Repo.preload(schema, [:user, :transaction])}
      error -> error
    end
  end

  def delete(params) do
    Repo.delete(params)
  end

  def get_by_id(id) do
    Currency
    |> Repo.get(id)
    |> Repo.preload([:user, :transaction])
  end

  def get_all(id) do
    from(w in Currency, where: w.user_id == ^id)
    |> Repo.all()
  end
end
