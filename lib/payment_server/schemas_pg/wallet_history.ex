defmodule PaymentServer.SchemasPg.WalletHistory do
  import Ecto.Query, warn: false
  alias PaymentServer.Repo

  alias PaymentServer.SchemasPg.WalletHistory.TransactionHistory

  def create(params \\ %{}, options \\ []) do
    params
    |> TransactionHistory.create_changeset()
    |> Repo.insert(options)
  end

  def update(wallet_history, params) do
    wallet_history
    |> TransactionHistory.changeset(params)
    |> Repo.update()
  end

  def delete(wallet_history) do
    Repo.delete(wallet_history)
  end

  def get_by_id(id) do
    TransactionHistory
    |> Repo.get(id)
    |> Repo.preload([:user, :currency])
  end

  def get_by_wallet_id(id) do
    from(wh in TransactionHistory, where: wh.currency_id == ^id)
    |> Repo.all()
  end
end
