defmodule PaymentServerWeb.Types.WalletType do
  use Absinthe.Schema.Notation

  object :wallet_type do
    field :id, :id
    field :type, :string
    field :amount, :float
    field :user, :user_type
  end

  object :currency_type do
    field :label, :string
    field :value, :string
  end

  object :value_update_result do
    field :amount, :float
    field :default_currency, :string
  end

  object :all_currencies_result do
    field :rate, :float
    field :currency_to, :string
    field :currency_from, :string
  end

  input_object :wallet_transfer_input_type do
    field :user_id, non_null(:integer)
    field :wallet_type, non_null(:string)
    field :requested_amount, non_null(:float)
  end

  input_object :wallet_convert_input_type do
    field :currency_to, non_null(:string)
    field :currency_from, non_null(:string)
  end

  input_object :wallet_update_type do
    field :id, non_null(:id)
    field :type, :string
    field :amount, :float
  end

  input_object :wallet_input_type do
    field :type, non_null(:string)
  end

  input_object :wallets_query_input do
    field :first, :integer
    field :after, :integer
    field :before, :integer
  end
end
