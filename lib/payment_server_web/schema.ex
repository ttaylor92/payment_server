defmodule PaymentServerWeb.Schema do
  use Absinthe.Schema

  alias PaymentServerWeb.{Schemas, Types, Subscriptions}

  import_types Schemas.UserSchema
  import_types Schemas.WalletSchema
  import_types Subscriptions.WalletSubscriptions
  import_types Types.MiscType

  query do
    import_fields :user_queries
    import_fields :wallet_queries
  end

  mutation do
    import_fields :user_mutations
    import_fields :wallet_mutations
  end

  subscription do
    import_fields :wallet_subscriptions
  end
end
