defmodule PaymentServer.GraphqlApi.Types.WalletHistory do
  use Absinthe.Schema.Notation


  object :history_type do
    field :id, :id
    field :amount, :integer
    field :type, :string
    field :currency_id, :id
    field :user, :user_type
  end

  input_object :history_input_type do
    field :amount,  non_null(:integer)
    field :type,  non_null(:string)
    field :currency_id,  non_null(:id)
  end
end
