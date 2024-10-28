defmodule PaymentServerWeb.Schema.Queries.WalletHistoryMutation do
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Resolvers.WalletHistoryResolver

  object :wallet_history_mutations do
    @desc "Create a wallet history"
    field :create_wallet_history, type: :history_type do
      arg :input, non_null(:history_input_type)
      resolve(&WalletHistoryResolver.create_wallet_history/3)
    end
  end
end
