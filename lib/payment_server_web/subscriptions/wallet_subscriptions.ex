defmodule PaymentServerWeb.Subscriptions.WalletSubscriptions do
  use Absinthe.Schema.Notation

  @subscribe_message "Subscribe to recieve 1 minute updates for"
  @trigger_message "remember to add account to notification DB via mutations via trigger"

  object :wallet_subscriptions do
    @desc "#{@subscribe_message} total user worth notifications, #{@trigger_message}: subscribeToTotalWorthUpdate"
    field :total_worth_update, :value_update_result do
      config fn _, %{context: %{ current_user: current_user }} ->
        {:ok, topic: current_user.id}
      end
    end

    @desc "#{@subscribe_message} currency notifications, #{@trigger_message}: subscribeToCurrencyUpdate"
    field :currency_update, :value_update_result do
      arg :currency, non_null(:string)
      config fn args, %{context: %{ current_user: _current_user }} ->
        {:ok, topic: args.currency}
      end
    end

    @desc "#{@subscribe_message} all currency notifications, #{@trigger_message}: subscribeToAllCurrencyUpdate"
    field :all_currencies_update, list_of(:all_currencies_result) do
      config fn _, %{context: %{ current_user: _current_user }} ->
        {:ok, topic: "all_currencies"}
      end
    end
  end
end
