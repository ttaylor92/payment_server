defmodule PaymentServerWeb.Schema.Queries.WalletHistoryQuery do
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Resolvers.WalletHistoryResolver

  object :wallet_history_queries do
    @desc "Get wallet history"
    field :get_wallet_history, type: :history_type do
      arg :id, non_null(:id)
      resolve &WalletHistoryResolver.get_wallet_history/3
    end
  end
end
