defmodule PaymentServerWeb.Test do
  use Phoenix.Component

  def test_component(assigns) do
    ~H"""
      <div>
        <p><%= @message %></p>
      </div>
    """
  end
end
