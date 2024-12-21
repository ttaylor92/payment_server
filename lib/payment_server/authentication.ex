defmodule PaymentServer.Authentication do
  alias PaymentServer.SchemasPg.Accounts
  alias Utils.AuthToken

  @doc """
  Attempts to authenticate a user based on the provided email and password.

  ## Arguments:

  * `email` (String): The email address of the user attempting to login.
  * `password` (String): The plain text password entered by the user.

  ## Return Value:

  * Returns `{:ok, %{token: token, user: user}}` if the email and password combination is valid, where `token` is the generated authentication token and `user` is a map containing user details.
  * Returns `{:error, reason}` if the authentication fails, where `reason` is a string indicating the failure reason.

  ## Errors:

  * The function itself doesn't explicitly raise errors. However, potential errors can occur during database interaction or password hashing:
      * If the user with the provided email is not found in the database, `Repo.get_by` will return `nil`.
      * If there's an issue with password hashing or verification using Argon2, an `Argon2.Error` might be raised (handled internally).

  ## Example Usage:

  ```elixir
  user = PaymentServer.Authentication.authenticate_user("john.doe@example.com", "secret_password")

  case user do
    {:ok, %{token: token, user: user_info}} ->
      # User authenticated, proceed with authorization or session creation
    {:error, reason} ->
      # Authentication failed, handle invalid credentials
  end
  """
  def authenticate_user(email, password) do
    with {:ok, account} <- Accounts.get_user_by_email(email) do
      case Argon2.verify_pass(password, account.password_hash) do
        true -> {:ok, %{token: AuthToken.create(account), user: %{email: account.email}}}
        false -> {:error, "No Matching account found."}
      end
    end
  end
end
