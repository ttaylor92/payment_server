defmodule PaymentServerWeb.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: PaymentServerWeb.Schema

  alias PaymentServer.Repo
  alias PaymentServer.SchemasPg.Accounts.User

  ## Channels
  channel "graphql:*", Absinthe.Phoenix.Channel

  def connect(params, socket, _connect_info) do
    case current_user(params) do
      {:ok, user} ->
        {:ok, Absinthe.Phoenix.Socket.put_options(socket, context: %{current_user: user})}

      {:error, message} -> {:error, reason: message}
    end
  end

  def current_user(%{"Authorization" => authorization_token}) do
    "Bearer " <> token = authorization_token

    case Utils.AuthToken.verify(token) do
      {:ok, user_id} ->
        case Repo.preload(Repo.get(User, user_id), [:curriences]) do
          nil -> {:error, message: "Invalid authorization token"}
          user -> {:ok, user}
        end

      {:error, _reason} ->
        {:error, message: "Invalid authorization token"}
    end
  end

  def current_user(_) do
    {:error, message: "Unauthenticated"}
  end

  def id(_socket), do: nil
end
