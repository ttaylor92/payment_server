defmodule PaymentServer.Authentication do
  alias PaymentServer.SchemasPg.Accounts

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
  def authenticate_user(email, password) do
    with {:ok, account} <- Accounts.get_user_by_email(email) do
      case Argon2.verify_pass(password, account.password_hash) do
        true -> {:ok, account}
        false -> {:error, "No Matching account found."}
      end
    end
  end
end
