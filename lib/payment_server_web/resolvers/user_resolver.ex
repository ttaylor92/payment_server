defmodule PaymentServerWeb.Resolvers.UserResolver do
  alias PaymentServer.Authentication
  alias PaymentServer.SchemasPg.Accounts
  alias Utils.AuthToken

  def users(args, _, %{context: %{current_user: _current_user}}) do
    {:ok, Accounts.list_users(args, preload: :curriences)}
  end

  def users(_, _, _) do
    {:error, message: "Unauthenticated!!!"}
  end

  def create_user(_, %{input: input}, _) do
    case Accounts.create_user(input) do
      {:ok, account} -> {:ok, account}

      {:error, changeset} ->
        {:error,
         message: "User creation failed!", details: Utils.GraphqlErrorHandler.errors_on(changeset)}
    end
  end

  def get_user(_, %{id: id}, %{context: %{current_user: _current_user}}) do
    case Accounts.get_user(id) do
      {:error, _} -> {:error, message: "User not found!"}
      {:ok, user} -> {:ok, user}
    end
  end

  def get_user(_, _, %{context: %{current_user: current_user}}) do
    {:ok, current_user}
  end

  def get_user(_, _, _) do
    {:error, message: "Unauthenticated!!!"}
  end

  def sign_in(_, %{email: email, password: password}, _) do
    case Authentication.authenticate_user(email, password) do
      {:ok, %Accounts.User{} = user} ->
        {:ok, %{token: AuthToken.create(user), user: %{email: user.email}}}

      {:error, _} ->
        {:error, message: "Signin failed!"}
    end
  end

  def delete_user(_, _, %{context: %{current_user: current_user}}) do
    case Accounts.delete_user(current_user) do
      {:ok, _account} -> {:ok, %{message: "Account deleted."}}

      {:error, changeset} ->
        {:error,
         message: "User deletion failed!", details: Utils.GraphqlErrorHandler.errors_on(changeset)}
    end
  end

  def delete_user(_, _, _) do
    {:error, message: "Unauthenticated!!!"}
  end

  def update_user(_, %{input: input}, %{context: %{current_user: current_user}}) do
    case Accounts.update_user(current_user, input) do
      {:ok, result} -> {:ok, result}

      {:error, changeset} ->
        {:error,
         message: "User update failed!", details: Utils.GraphqlErrorHandler.errors_on(changeset)}
    end
  end

  def update_user(_, _, _) do
    {:error, message: "Unauthenticated!!!"}
  end
end
