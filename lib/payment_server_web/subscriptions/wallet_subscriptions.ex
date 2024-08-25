defmodule PaymentServerWeb.Subscriptions.WalletSubscriptions do
  use Absinthe.Schema.Notation

  @subscribe_message "Subscribe to recieve 1 minute updates for"

  object :wallet_subscriptions do
    @desc "Subscribe to recieve total user worth notifications"
    field :total_worth_update, :value_update_result do
      config fn _, %{context: %{ current_user: current_user }} ->
        {:ok, topic: current_user.id}
      end
    end

    @desc "#{@subscribe_message} currency notifications"
    field :currency_update, :value_update_result do
      arg :currency, non_null(:string)
      config fn args, %{context: %{ current_user: _current_user }} ->
        {:ok, topic: "currency:#{args.currency}"}
      end
    end

    @desc "#{@subscribe_message} all currency notifications"
    field :all_currencies_update, list_of(:all_currencies_result) do
      config fn _, %{context: %{ current_user: _current_user }} ->
        {:ok, topic: "all_currencies"}
      end
    end
  end
end
