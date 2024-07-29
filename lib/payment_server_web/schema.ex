defmodule PaymentServerWeb.Schema do
  use Absinthe.Schema

  alias PaymentServerWeb.Schemas
  alias PaymentServerWeb.Types

  import_types Schemas.UserSchema
  import_types Schemas.WalletSchema
  import_types Schemas.SubscriptionSchema
  import_types Types.MiscType

  query do
    import_fields :user_queries
    import_fields :wallet_queries
  end

  mutation do
    import_fields :user_mutations
    import_fields :wallet_mutations
    import_fields :subscription_mutations
  end

  subscription do
    field :total_worth_update, :value_update_result do
      config fn _, %{context: %{ current_user: current_user }} ->
        {:ok, topic: current_user.id}
      end
    end

    field :currency_update, :value_update_result do
      arg :currency, non_null(:string)
      config fn args, _ -> {:ok, topic: args.currency} end
    end

    field :all_currencies_update, list_of(:all_currencies_result) do
      config fn _, _ -> {:ok, topic: "all_currencies"} end
    end
  end
end
