defmodule PaymentServer.Support.UserFactory do
  @behaviour FactoryEx

  def schema, do: PaymentServer.SchemasPg.Accounts.User

  def repo, do: PaymentServer.Repo

  def build(params \\ %{}) do
    default = %{
      email: "user@example.com",
      password: "secret",
      password_confirmation: "secret",
      first_name: "first",
      last_name: "last"
    }

    Map.merge(default, params)
  end

  def build_param_map(params \\ %{}) do
    FactoryEx.build_params(__MODULE__, params)
  end
end
