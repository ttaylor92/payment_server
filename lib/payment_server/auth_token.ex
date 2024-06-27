defmodule PaymentServer.AuthToken do
  @salt "any salt"

  def create(user) do
    Phoenix.Token.sign(PaymentServerWeb.Endpoint, @salt, user.id)
  end

  def verify(token) do
    Phoenix.Token.verify(PaymentServerWeb.Endpoint, @salt, token, max_age: 60 * 60 * 24)
  end
end
