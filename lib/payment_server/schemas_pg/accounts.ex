defmodule PaymentServer.SchemasPg.Accounts do
  @moduledoc """
  The Accounts context.

  This context is responsible for managing user accounts, including creation,
  retrieval, updating, and deletion of user data.
  """

  alias EctoShorts.Actions
  alias PaymentServer.SchemasPg.Accounts.User

  @spec list_users(map()) :: list(User.t())
  @spec list_users(map(), keyword()) :: list(User.t())
  def list_users(params \\ %{}, opts \\ []) do
    Actions.all(User, params, opts)
  end

  @spec get_user(integer()) :: {:ok, User.t()} | {:error, any()}
  @spec get_user(integer(), keyword()) :: {:ok, User.t()} | {:error, any()}
  def get_user(id, opts \\ []) do
    Actions.find(User, %{id: id, preload: Keyword.get(opts, :preload, [])})
  end

  @spec get_user_by_email(String.t()) :: {:ok, User.t()} | {:error, String.t()}
  @spec get_user_by_email(String.t(), keyword()) :: {:ok, User.t()} | {:error, String.t()}
  def get_user_by_email(email, opts \\ []) do
    Actions.find(User, %{email: email, preload: Keyword.get(opts, :preload, [])})
  end

  @spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs \\ %{}) do
    Actions.create(User, attrs)
  end

  @spec update_user(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  @spec update_user(User.t(), map(), keyword()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_user(%User{} = user, attrs \\ %{}, opts \\ []) do
    Actions.update(User, user, Map.put(attrs, :preload, Keyword.get(opts, :preload, [])))
  end

  @spec delete_user(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def delete_user(%User{} = user) do
    Actions.delete(user)
  end
end
