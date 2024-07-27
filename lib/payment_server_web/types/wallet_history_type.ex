defmodule PaymentServer.Types.WalletHistory do
  use Absinthe.Schema.Notation

  enum :transaction_type do
    value :sent, as: "sent"
    value :received, as: "received"
  end

  object :history_type do
    field :id, :id
    field :amount, :integer
    field :type, :transaction_type
    field :currency, :wallet_type
    field :user, :user_type
  end

  input_object :history_input_type do
    field :amount,  non_null(:integer)
    field :type,  non_null(:transaction_type)
    field :currency_id,  non_null(:integer)
  end
end
