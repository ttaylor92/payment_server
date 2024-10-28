defmodule PaymentServerWeb.Schema.Queries.WalletQuery do
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Resolvers.WalletResolver

  object :wallet_queries do
    @desc "Get a user's wallet"
    field :wallet, type: :wallet_type do
      arg :wallet_type, non_null(:string)
      resolve &WalletResolver.get_wallet/3
    end

    @desc "Get all of a user's wallets"
    field :wallets, type: list_of(:wallet_type) do
      resolve &WalletResolver.get_wallets/3
    end

    @desc "Get a list of currencies that can be used to create a user's wallet"
    field :currencies, type: list_of(:currency_type) do
      resolve &WalletResolver.get_currencies/3
    end
  end
end
