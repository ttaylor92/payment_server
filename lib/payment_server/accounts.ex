defmodule PaymentServer.Accounts do
  @moduledoc """
  The Accounts context.

  This context is responsible for managing user accounts, including creation,
  retrieval, updating, and deletion of user data.
  """

  import Ecto.Query, warn: false
  alias PaymentServer.Repo

  alias PaymentServer.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user(id) do
    Repo.get(User, id) |> Repo.preload([:curriences])
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    User.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = changeset, attrs \\ %{}) do
    User.update_changeset(changeset, attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Attempts to authenticate a user based on the provided email and password.

  ## Arguments:

  * `email` (String): The email address of the user attempting to login.
  * `password` (String): The plain text password entered by the user.

  ## Return Value:

  * The function returns a `User` struct if the email and password combination is valid, otherwise it returns `nil`.

  ## Errors:

  * The function itself doesn't explicitly raise errors. However, potential errors can occur during database interaction or password hashing:
      * If the user with the provided email is not found in the database, `Repo.get_by` will return `nil`.
      * If there's an issue with password hashing or verification using Argon2, an `Argon2.Error` might be raised (handled internally).

  ## Example Usage:

  ```elixir
  # Assuming user_context is a UserContext module
  user = user_context.authenticate("john.doe@example.com", "secret_password")

  if user do
    # User authenticated, proceed with authorization or session creation
  else
    # Authentication failed, handle invalid credentials
  end
  """
  def authenticate(email, password) do
    case User |> Repo.get_by(email: email) do
      nil -> {:error, "No Matching account found."}
      account -> case Argon2.verify_pass(password, account.password_hash) do
        true -> {:ok, account}
        false -> {:error, "No Matching account found."}
      end
    end
  end
end
