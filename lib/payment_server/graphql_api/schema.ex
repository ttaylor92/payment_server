defmodule PaymentServer.GraphqlApi.Schema do
  use Absinthe.Schema

  alias PaymentServer.GraphqlApi.Schemas
  alias PaymentServer.GraphqlApi.Types

  import_types Schemas.UserSchema
  import_types Schemas.WalletSchema
  import_types Schemas.WalletHistorySchema
  import_types Types.MiscType

  query do
    import_fields :user_queries
    import_fields :wallet_queries
    import_fields :wallet_history_queries
  end

  mutation do
    import_fields :user_mutations
    import_fields :wallet_mutations
    import_fields :wallet_history_mutations
  end
end
