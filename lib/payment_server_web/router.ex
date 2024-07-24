defmodule PaymentServerWeb.Router do
  use PaymentServerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug PaymentServerWeb.Plugs.SetCurrentUser
  end

  scope "/api" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug, schema: PaymentServer.GraphqlApi.Schema

    if Mix.env() == :dev do
      forward "/graphiql", Absinthe.Plug.GraphiQL,
        schema: PaymentServer.GraphqlApi.Schema,
        socket: PaymentServerWeb.UserSocket,
        interface: :playground
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:payment_server, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: PaymentServerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
