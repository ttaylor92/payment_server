defmodule PaymentServer.Schemas.WalletHistorySchema do
  use Absinthe.Schema.Notation

  alias PaymentServer.Resolvers
  alias PaymentServer.Types

  # Types
  import_types(Types.WalletHistory)

  object :wallet_history_queries do

    @desc "Get wallet history"
    field :get_wallet_history, type: :history_type do
      arg(:id, non_null(:id))
      resolve &Resolvers.WalletHistoryResolver.get_wallet_history/3
    end
  end

  object :wallet_history_mutations do

    @desc "Create a wallet history"
    field :create_wallet_history, type: :history_type do
      arg(:input, non_null(:history_input_type))
      resolve(&Resolvers.WalletHistoryResolver.create_wallet_history/3)
    end
  end
end
