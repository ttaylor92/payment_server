defmodule PaymentServer.GraphqlApi.Schemas.WalletSchema do
  use Absinthe.Schema.Notation

  alias PaymentServer.GraphqlApi.Resolvers.WalletResolver
  alias PaymentServer.GraphqlApi.Types

  # Types
  import_types(Types.WalletType)

  object :wallet_queries do

    @desc "Get a user's wallet"
    field :get_wallet, type: :wallet_type do
      arg(:wallet_type, non_null(:string))
      resolve(&WalletResolver.get_wallet/3)
    end

    @desc "Get all of a user's wallets"
    field :get_wallets, type: list_of(:wallet_type) do
      resolve(&WalletResolver.get_wallets/3)
    end

    @desc "Get a list of currencies that can be used to create a user's wallet"
    field :get_currencies, type: list_of(:currency_type) do
      resolve(&WalletResolver.get_currencies/3)
    end

    @desc "Get user's total worth"
    field :get_total_worth, type: :total_worth_result do
      arg(:currency, non_null(:string))
      resolve(&WalletResolver.get_total_worth/3)
    end
  end

  object :wallet_mutations do

    @desc "Create a user wallet"
    field :create_wallet, type: :wallet_type do
      arg(:input, non_null(:wallet_input_type))
      resolve(&WalletResolver.create_wallet/3)
    end

    @desc "Update a user wallet"
    field :update_wallet, type: :wallet_type do
      arg(:input, non_null(:wallet_update_type))
      resolve(&WalletResolver.update_wallet/3)
    end

    @desc "Process a wallet transfer request"
    field :process_transfer_request, type: :wallet_type do
      arg(:input, non_null(:wallet_transfer_input_type))
      resolve(&WalletResolver.process_transaction/3)
    end

    @desc "Process a wallet conversion request"
    field :process_conversion_request, type: :wallet_type do
      arg(:input, non_null(:wallet_convert_input_type))
      resolve(&WalletResolver.process_wallet_conversion/3)
    end

    @desc "Delete a user wallet"
    field :delete_wallet, type: :delete_response_type do
      arg(:id, non_null(:id))
      resolve(&WalletResolver.delete_wallet/3)
    end
  end
end
