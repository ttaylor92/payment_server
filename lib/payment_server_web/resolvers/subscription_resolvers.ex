defmodule PaymentServerWeb.Resolvers.SubscriptionResolvers do
  alias PaymentServer.PeriodicTask

  def subscribe_to_total_worth(_, _, %{context: %{current_user: current_user}}) do
    PeriodicTask.add_user_id(:notification, current_user.id)
    {:ok, true}
  end

  def subscribe_to_total_worth(_, _, _context) do
    {:error, message: "Unauthenticated!!!"}
  end

  def unsubscribe_from_total_worth(_, _, %{context: %{current_user: current_user}}) do
    PeriodicTask.remove_user_id(:notification, current_user.id)
    {:ok, true}
  end

  def unsubscribe_from_total_worth(_, _, _context) do
    {:error, message: "Unauthenticated!!!"}
  end

  def subscribe_to_currency(_, %{currency: currency}, %{context: %{current_user: current_user}}) do
    PeriodicTask.add_user_id(:watch_currency, current_user.id, currency)
    {:ok, true}
  end

  def subscribe_to_currency(_, %{currency: _currency}, _context) do
    {:error, message: "Unauthenticated!!!"}
  end

  def unsubscribe_from_currency(_, %{currency: currency}, %{context: %{current_user: current_user}}) do
    PeriodicTask.remove_user_id(:watch_currency, current_user.id, currency)
    {:ok, true}
  end

  def unsubscribe_from_currency(_, %{currency: _currency}, _context) do
    {:error, message: "Unauthenticated!!!"}
  end

  def unsubscribe_from_all_currency(_, _, %{context: %{current_user: current_user}}) do
    PeriodicTask.remove_user_id(:all_currencies, current_user.id)
    {:ok, true}
  end

  def unsubscribe_from_all_currency(_, _, _context) do
    {:error, message: "Unauthenticated!!!"}
  end

  def subscribe_to_all_currency(_, _, %{context: %{current_user: current_user}}) do
    PeriodicTask.add_user_id(:all_currencies, current_user.id)
    {:ok, true}
  end

  def subscribe_to_all_currency(_, _, _context) do
    {:error, message: "Unauthenticated!!!"}
  end
end
