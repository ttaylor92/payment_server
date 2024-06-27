defmodule PaymentServer.GraphqlApi.Types.SessionType do
  use Absinthe.Schema.Notation

  object :session do
    field :token, :string
  end

  input_object :session_input do
    field :email, :string
    field :password, :string
  end
end
