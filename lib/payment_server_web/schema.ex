defmodule PaymentServerWeb.Schema do
  use Absinthe.Schema

  alias PaymentServerWeb.Types
  alias PaymentServerWeb.Schema.{
    Queries,
    Mutations,
    Subscriptions
  }

  import_types Subscriptions.WalletSubscriptions
  import_types Queries.{
    UserQuery,
    WalletQuery
  }

  import_types Mutations.{
    UserMutation,
    WalletMutation
  }

  import_types Types.{
    MiscType,
    UserType,
    SessionType,
    WalletType
  }

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
