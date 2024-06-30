defmodule PaymentServer.GraphqlApi.Schema do
  use Absinthe.Schema

  alias PaymentServer.GraphqlApi.Resolvers
  alias PaymentServer.GraphqlApi.Types

  # Types
  import_types(Types.UserType)
  import_types(Types.SessionType)
  import_types(Types.WalletType)

  query do

    @desc "Get a list of all users"
    field :users, list_of(:user_type) do
      resolve(&Resolvers.UserResolver.users/3)
    end

    @desc "Get a user's wallet"
    field :get_wallet, type: :wallet_type do
      arg(:id, non_null(:id))
      resolve(&Resolvers.WalletResolver.get_wallet/3)
    end
  end

  mutation do

    @desc "Register a user"
    field :register_user, type: :user_type do
      arg(:input, non_null(:user_input_type))
      resolve(&Resolvers.UserResolver.create_user/3)
    end

    @desc "Sign a user in"
    field :sign_in, type: :session do
      arg(:input, non_null(:session_input))
      resolve(&Resolvers.UserResolver.sign_in/3)
    end

    @desc "Create a user wallet"
    field :create_wallet, type: :wallet_type do
      arg(:input, non_null(:wallet_input_type))
      resolve(&Resolvers.WalletResolver.create_wallet/3)
    end
  end
end
