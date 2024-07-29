defmodule PaymentServerWeb.Schemas.SubscriptionSchema do
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Resolvers.SubscriptionResolvers

  object :subscription_mutations do

    @desc "Remove user from total worth update"
    field :unsubscribe_from_total_worth_update, type: :boolean do
      resolve &SubscriptionResolvers.unsubscribe_from_total_worth/3
    end

    @desc "Add user to total worth update"
    field :subscribe_to_total_worth_update, type: :boolean do
      resolve &SubscriptionResolvers.subscribe_to_total_worth/3
    end

    @desc "Remove user from all currency update"
    field :unsubscribe_from_all_currency_update, type: :boolean do
      resolve &SubscriptionResolvers.unsubscribe_from_all_currency/3
    end

    @desc "Add user to all currency update"
    field :subscribe_to_all_currency_update, type: :boolean do
      resolve &SubscriptionResolvers.subscribe_to_all_currency/3
    end

    @desc "Remove user from currency update"
    field :unsubscribe_from_currency_update, type: :boolean do
      arg :currency, non_null(:string)
      resolve &SubscriptionResolvers.unsubscribe_from_currency/3
    end

    @desc "Add user to currency update"
    field :subscribe_to_currency_update, type: :boolean do
      arg :currency, non_null(:string)
      resolve &SubscriptionResolvers.subscribe_to_currency/3
    end
  end
end
