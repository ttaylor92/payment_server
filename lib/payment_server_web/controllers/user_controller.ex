defmodule PaymentServerWeb.UserController do
  use PaymentServerWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def search conn, %{"id" => id} do
    render(conn, :search, id: id)
  end
end
