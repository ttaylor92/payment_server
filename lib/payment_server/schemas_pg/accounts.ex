defmodule PaymentServer.SchemasPg.Accounts do
  @moduledoc """
  The Accounts context.

  This context is responsible for managing user accounts, including creation,
  retrieval, updating, and deletion of user data.
  """

  import Ecto.Query, only: [from: 1]

  alias PaymentServer.Repo
  alias EctoShorts.{Actions, CommonFilters}
  alias PaymentServer.SchemasPg.Accounts.User


  def list_users(params \\ %{}, opts \\ []) do
    from(u in User)
    |> CommonFilters.convert_params_to_filter(params)
    |> Repo.all()
    |> maybe_preload(opts)
  end


  def get_user(id, opts \\ []) do
    case Actions.get(User, id) do
      nil -> nil
      user -> maybe_preload(user, opts)
    end
  end

  def get_user_by_email(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, "No Matching account found."}
      account -> {:ok, account}
    end
  end


  def create_user(attrs \\ %{}) do
    Repo.insert(User.create_changeset(attrs))
  end

  def update_user(%User{} = changeset, attrs \\ %{}) do
    Repo.update(User.update_changeset(changeset, attrs))
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  defp maybe_preload(schema_data, opts) do
    case opts[:preload] do
      nil -> schema_data
      preload -> Repo.preload(schema_data, preload)
    end
  end
end
