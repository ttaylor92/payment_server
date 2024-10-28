defmodule PaymentServerWeb.Schema.Queries.UserQuery do
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Resolvers.UserResolver

  object :user_queries do

    @desc "Get a list of all users"
    field :users, list_of(:user_type) do
      resolve &UserResolver.users/3
    end

    @desc "Get a user if an id is given otherwise authenticated user is given"
    field :user, :user_type do
      arg :id, :id
      resolve &UserResolver.get_user/3
    end
  end
end
