defmodule PaymentServer.GraphqlApi.Resolvers.SubscriptionResolvers do
  alias PaymentServer.PeriodicTask

  def subscribe_to_total_worth(_, %{user_id: user_id}, %{context: %{current_user: _current_user}}) do
    PeriodicTask.add_user_id(user_id)
    {:ok, true}
  end

  def unsubscribe_from_total_worth(_, %{user_id: user_id}, %{context: %{current_user: _current_user}}) do
    PeriodicTask.remove_user_id(user_id)
    {:ok, true}
  end
end
