defmodule PaymentServer.AuthenticationTest do
  use PaymentServer.DataCase

  alias PaymentServer.Authentication
  alias PaymentServer.SchemasPg.Accounts
  alias PaymentServer.Support.UserFactory

  describe "authenticate_user/2" do
    test "authenticates the user with correct credentials" do
      {:ok, user} =
        Accounts.create_user(UserFactory.build_param_map())

      assert {:ok, authenticated_user} = Authentication.authenticate_user(user.email, "secret")
      assert authenticated_user.user.email === user.email
    end

    test "returns an error tuple with incorrect credentials" do
      {:ok, user} =
        Accounts.create_user(UserFactory.build_param_map())

      assert {:error, "No Matching account found."} =
               Authentication.authenticate_user(user.email, "wrongpassword")
    end
  end
end
