defmodule PaymentServer.Schema do
  use Absinthe.Schema

  alias PaymentServer.Schemas
  alias PaymentServer.Types
  alias PaymentServer.Resolvers.SubscriptionResolvers

  import_types Schemas.UserSchema
  import_types Schemas.WalletSchema
  import_types Types.MiscType

  query do
    import_fields :user_queries
    import_fields :wallet_queries
  end

  mutation do
    import_fields :user_mutations
    import_fields :wallet_mutations

    field :unsubscribe_from_total_worth_update, type: :boolean do
      arg :user_id, non_null(:id)
      resolve &SubscriptionResolvers.unsubscribe_from_total_worth/3
    end

    field :subscribe_to_total_worth_update, type: :boolean do
      arg :user_id, non_null(:id)
      resolve &SubscriptionResolvers.subscribe_to_total_worth/3
    end

    field :unsubscribe_from_currency_update, type: :boolean do
      arg :currency, non_null(:string)
      resolve &SubscriptionResolvers.unsubscribe_from_currency/3
    end

    field :subscribe_to_currency_update, type: :boolean do
      arg :currency, non_null(:string)
      resolve &SubscriptionResolvers.subscribe_to_currency/3
    end
  end

  subscription do
    field :total_worth_update, :value_update_result do
      arg :user_id, non_null(:id)
      config fn args, _ -> {:ok, topic: args.user_id} end
    end

    field :currency_update, :value_update_result do
      arg :currency, non_null(:string)
      config fn args, _ -> {:ok, topic: args.currency} end
    end

    field :all_currencies_update, :value_update_result do
      config fn _, _ -> {:ok, topic: "all_currencies"} end
    end
  end
end
