defmodule PaymentServerWeb.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: PaymentServerWeb.Schema

  alias PaymentServer.Repo
  alias PaymentServer.Accounts.User

  ## Channels
  channel "graphql:*", Absinthe.Phoenix.Channel

  def connect(params, socket, _connect_info) do
    if Mix.env() === :test do
      {:ok, socket}
    else
      current_user(params)
      |> case do
        {:ok, user} ->
          socket = Absinthe.Phoenix.Socket.put_options(socket, context: %{ current_user: user })
          {:ok, socket}
        {:error, _} -> {:error, reason: "Unauthenticated"}
      end
    end
  end

  def current_user(%{"authorization" => authorization_token}) do
    "Bearer " <> token = authorization_token
    case Utils.AuthToken.verify(token) do
      {:ok, user_id} -> User
        |> Repo.get(user_id)
        |> Repo.preload([:curriences])
        |> case do
          nil -> {:error, "invalid authorization token"}
          user -> {:ok, user}
        end
      {:error, _reason} -> {:error, "invalid authorization token"}
    end
  end

  def id(_socket), do: nil
end
