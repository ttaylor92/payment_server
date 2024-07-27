defmodule PaymentServer.GraphqlApi.Resolvers.SubscriptionResolvers do
  alias PaymentServer.PeriodicTask

  def subscribe_to_total_worth(_, _, %{context: %{current_user: current_user}}) do
    PeriodicTask.add_user_id(:notification, current_user.id)
    {:ok, true}
  end

  def unsubscribe_from_total_worth(_, _, %{context: %{current_user: current_user}}) do
    PeriodicTask.remove_user_id(:notification, current_user.id)
    {:ok, true}
  end

  def subscribe_to_currency(_, %{currency: currency}, %{context: %{current_user: current_user}}) do
    PeriodicTask.add_user_id(:watch_currency, current_user.id, currency)
    {:ok, true}
  end

  def unsubscribe_from_currency(_, %{currency: currency}, %{context: %{current_user: current_user}}) do
    PeriodicTask.remove_user_id(:watch_currency, current_user.id, currency)
    {:ok, true}
  end
end
