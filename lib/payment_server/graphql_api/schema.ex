defmodule PaymentServer.GraphqlApi.Schema do
  use Absinthe.Schema

  alias PaymentServer.GraphqlApi.Resolvers
  alias PaymentServer.GraphqlApi.Types

  # Types
  import_types(Types.UserType)

  query do

    @desc "Get a list of all users"
    field :users, list_of(:user_type) do
      resolve(&Resolvers.UserResolver.users/3)
    end
  end

  mutation do

    @desc "Register a user"
    field :register_user, type: :user_type do
      arg(:input, non_null(:user_input_type))
      resolve(&Resolvers.UserResolver.create_user/3)
    end
  end
end
