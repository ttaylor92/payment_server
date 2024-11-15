defmodule PaymentServer.Services.AuthenticationTest do
  alias PaymentServer.Services.Authentication
  alias PaymentServer.SchemasPg.Accounts
  alias PaymentServer.Support.UserFactory

  describe "authenticate_user/2" do
    test "authenticates the user with correct credentials" do
      {:ok, user} =
        UserFactory.build_param_map()
        |> Accounts.create_user()

      {:ok, authenticated_user} = Accounts.authenticate_user(user.email, "secret")
      assert authenticated_user.email == user.email
    end

    test "throws an error with incorrect credentials" do
      {:ok, user} =
        UserFactory.build_param_map()
        |> Accounts.create_user()

      assert {:error, "No Matching account found."} =
               Authentication.authenticate_user(user.email, "wrongpassword")
    end
  end
end
