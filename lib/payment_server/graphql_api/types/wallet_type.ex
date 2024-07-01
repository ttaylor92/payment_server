defmodule PaymentServer.GraphqlApi.Types.WalletType do
  use Absinthe.Schema.Notation

  object :wallet_type do
    field :id, :id
    field :type, :string
    field :amount, :integer
    field :user, :user_type
    field :transaction, list_of(:history_type)
  end

  input_object :wallet_update_type do
    field :id, non_null(:id)
    field :type, :string
    field :amount, :integer
  end

  input_object :wallet_input_type do
    field :type, non_null(:string)
  end
end
