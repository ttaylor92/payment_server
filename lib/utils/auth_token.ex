defmodule Utils.AuthToken do
  @salt "any salt"
  @days 3

  def create(user) do
    Phoenix.Token.sign(PaymentServerWeb.Endpoint, @salt, user.id, max_age: @days * 24 * 60 * 60)
  end

  def verify(token) do
    Phoenix.Token.verify(PaymentServerWeb.Endpoint, @salt, token, max_age: @days * 24 * 60 * 60)
  end
end
