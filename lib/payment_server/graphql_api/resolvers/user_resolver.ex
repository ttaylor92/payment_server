defmodule PaymentServer.GraphqlApi.Resolvers.UserResolver do

  alias PaymentServer.Accounts

  def users(_, _, _) do
    {:ok, Accounts.list_users()}
  end

  def create_user(_,%{input: input},_) do
    Accounts.create_user(input)
  end
end
