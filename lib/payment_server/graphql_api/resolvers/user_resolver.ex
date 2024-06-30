defmodule PaymentServer.GraphqlApi.Resolvers.UserResolver do

  alias PaymentServer.Accounts
  alias Utils.AuthToken

  def users(_, _, %{context: %{current_user: _current_user}}) do
    {:ok, Accounts.list_users()}
  end

  def create_user(_,%{input: input},_) do
    Accounts.create_user(input)
  end

  def sign_in(_,%{input: input},_) do
    case input do
      %{email: email, password: password} -> case Accounts.authenticate(email, password) do
          {:ok, %Accounts.User{} = user} -> {:ok, %{token: AuthToken.create(user), user: %{email: user.email}}}

          # details: GraphQL.Errors.extract(changeset)
          {:error, _changeset} -> {:error, message: "Signin failed!"}
        end
      _ -> {:error, message: "Signin failed!"}
    end
  end
end
