defmodule PaymentServerWeb.Types.MiscType do
  use Absinthe.Schema.Notation

  object :delete_response_type do
    field :message, :string
  end
end
