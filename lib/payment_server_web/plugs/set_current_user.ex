defmodule PaymentServerWeb.Plugs.SetCurrentUser do
  @behaviour Plug

  import Plug.Conn

  alias PaymentServer.Repo
  alias PaymentServer.Accounts.User

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  @doc """
  Return the current user context based on the authorization header
  """
  def build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"), {:ok, current_user} <- authorize(token) do
      %{current_user: current_user}
    else
      _ -> %{}
    end
  end

  defp authorize(token) do
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
end
