defmodule PaymentServer.GraphqlApi.Resolvers.UserResolver do

  alias PaymentServer.Accounts
  alias Utils.AuthToken

  def users(_, _, %{context: %{current_user: _current_user}}) do
    {:ok, Accounts.list_users()}
  end

  def users(_,_,_) do
    {:error, message: "Unauthenticated!!!"}
  end

  def create_user(_,%{input: input},_) do
    case Accounts.create_user(input) do
      {:ok, account} -> {:ok, account}
      {:error, changeset} -> {:error, message: "User creation failed!", details: Utils.GraphqlErrorHandler.errors_on(changeset)}
    end
  end

  def get_user(_, %{id: id}, %{context: %{current_user: current_user}}) do
    if id !== nil do
      case Accounts.get_user(id) do
        nil -> {:error, message: "User not found!"}
        user -> {:ok, user}
      end
    else
      {:ok, current_user}
    end
  end

  def get_user(_,_,_) do
    {:error, message: "Unauthenticated!!!"}
  end

  def sign_in(_,%{input: input},_) do
    case input do
      %{email: email, password: password} -> case Accounts.authenticate(email, password) do
          {:ok, %Accounts.User{} = user} -> {:ok, %{token: AuthToken.create(user), user: %{email: user.email}}}
          {:error, _} -> {:error, message: "Signin failed!"}
        end
      _ -> {:error, message: "Signin failed!"}
    end
  end

  def delete_user(_, _, %{context: %{current_user: current_user}}) do
    case Accounts.delete_user(current_user) do
      {:ok,} -> {:ok, message: "Account deleted."}
      {:error, changeset} -> {:error, message: "User deletion failed!", details: Utils.GraphqlErrorHandler.errors_on(changeset)}
    end
  end

  def delete_user(_,_,_) do
    {:error, message: "Unauthenticated!!!"}
  end

  def update_user(_, %{input: input}, %{context: %{current_user: current_user}}) do
    if input.id === current_user.id do
      case Accounts.update_user(input) do
        {:ok, result} -> {:ok,result}
        {:error, changeset} -> {:error, message: "User update failed!", details: Utils.GraphqlErrorHandler.errors_on(changeset)}
      end
    else
      {:error, "You do not have permissions to update this user."}
    end
  end

  def update_user(_,_,_) do
    {:error, message: "Unauthenticated!!!"}
  end
end
