defmodule PaymentServer.GraphqlApi.Schemas.WalletSchema do
  use Absinthe.Schema.Notation

  alias PaymentServer.GraphqlApi.Resolvers
  alias PaymentServer.GraphqlApi.Types

  # Types
  import_types(Types.WalletType)

  object :wallet_queries do

    @desc "Get a user's wallet"
    field :get_wallet, type: :wallet_type do
      arg(:id, non_null(:id))
      resolve(&Resolvers.WalletResolver.get_wallet/3)
    end

    @desc "Get all of a user's wallets"
    field :get_wallets, type: list_of(:wallet_type) do
      resolve(&Resolvers.WalletResolver.get_wallets/3)
    end
  end

  object :wallet_mutations do

    @desc "Create a user wallet"
    field :create_wallet, type: :wallet_type do
      arg(:input, non_null(:wallet_input_type))
      resolve(&Resolvers.WalletResolver.create_wallet/3)
    end

    @desc "Update a user wallet"
    field :update_wallet, type: :wallet_type do
      arg(:input, non_null(:wallet_update_type))
      resolve(&Resolvers.WalletResolver.update_wallet/3)
    end

    @desc "Delete a user wallet"
    field :delete_wallet, type: :delete_response_type do
      arg(:id, non_null(:id))
      resolve(&Resolvers.WalletResolver.delete_wallet/3)
    end
  end
end
