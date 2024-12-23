defmodule PaymentServerWeb.Types.UserType do
  use Absinthe.Schema.Notation

  object :user_type do
    field :id, :id
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :default_currency, :string
    field :curriences, list_of(:wallet_type)
  end

  input_object :user_input_type do
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :email, non_null(:string)
    field :password, non_null(:string)
    field :password_confirmation, non_null(:string)
    field :default_currency, :string
  end

  input_object :user_update_type do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string
    field :password_confirmation, :string
    field :default_currency, :string
  end

  input_object :users_query_input do
    field :first, :integer
    field :after, :integer
    field :before, :integer
  end
end
