defmodule PaymentServer.SchemasPg.Accounts do
  @moduledoc """
  The Accounts context.

  This context is responsible for managing user accounts, including creation,
  retrieval, updating, and deletion of user data.
  """

  alias EctoShorts.Actions
  alias PaymentServer.SchemasPg.Accounts.User
  alias PaymentServer.Repo

  @spec list_users(map(), keyword()) :: {:ok, list(User.t())}
  def list_users(params \\ %{}, opts \\ []) do
    Actions.all(User, params, opts)
  end

  @spec get_user(integer(), keyword()) :: {:ok, User.t()} | {:error, any()}
  def get_user(id, opts \\ []) do
    User
    |> Actions.find(%{id: id})
    |> maybe_preload(opts)
  end

  @spec get_user_by_email(String.t()) :: {:ok, User.t()} | {:error, String.t()}
  def get_user_by_email(email, opts \\ []) do
    case Actions.find(User, %{email: email}) do
      {:error, _} -> {:error, "No Matching account found."}
      {:ok, account} -> maybe_preload({:ok, account}, opts)
    end
  end

  @spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs \\ %{}) do
    Actions.create(User, attrs)
  end

  @spec update_user(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_user(%User{} = user, attrs \\ %{}, opts \\ []) do
    User
    |> Actions.update(user, attrs)
    |> maybe_preload(opts)
  end

  @spec delete_user(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def delete_user(%User{} = user) do
    Actions.delete(user)
  end

  defp maybe_preload({:error, data}, _opts) do
    {:error, data}
  end

  defp maybe_preload({:ok, schema_data}, opts) do
    case opts[:preload] do
      nil -> {:ok, schema_data}
      preload -> {:ok, Repo.preload(schema_data, preload)}
    end
  end
end
