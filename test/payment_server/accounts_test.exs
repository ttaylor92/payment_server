defmodule PaymentServer.AccountsTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServer.Accounts
  alias PaymentServer.Accounts.User
  alias PaymentServer.Support.UserFactory

  describe "list_users/0" do
    test "returns all users" do
      UserFactory.build_param_map() |> Accounts.create_user()
      fetch_users = Accounts.list_users()

      assert length(fetch_users) > 0
    end
  end

  describe "get_user/1" do
    test "returns the user with the given id" do
      {:ok, user} = UserFactory.build_param_map() |> Accounts.create_user()
      user_fetched = Accounts.get_user(user.id)

      assert user_fetched.email == user.email
    end

    test "raises Ecto.NoResultsError if the user does not exist" do
      assert nil == Accounts.get_user(-1)
    end
  end

  describe "create_user/1" do
    test "creates a user with valid data" do
      valid_attrs = UserFactory.build_param_map()
      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.email == valid_attrs.email
    end

    test "returns error changeset with invalid data" do
      invalid_attrs = %{UserFactory.build_param_map() | email: "email.com"}
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(invalid_attrs)
    end
  end

  describe "update_user/2" do
    test "updates the user with valid data" do
      {:ok, user} = UserFactory.build_param_map() |> Accounts.create_user()

      updated_user_req =
        %{UserFactory.build_param_map() | first_name: "new_first_name"}
        |> Map.put(:id, user.id)

      assert {:ok, updated_user} = Accounts.update_user(user, updated_user_req)
      assert updated_user.first_name == "new_first_name"
    end

    test "returns error changeset with invalid data" do
      {:ok, user} = UserFactory.build_param_map() |> Accounts.create_user()
      updated_user_req = %{UserFactory.build_param_map() | email: "email.com"}

      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, updated_user_req)
    end
  end

  describe "delete_user/1" do
    test "deletes the user" do
      {:ok, user} = UserFactory.build_param_map() |> Accounts.create_user()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert nil == Accounts.get_user(user.id)
    end
  end

  describe "authenticate/2" do
    test "authenticates the user with correct credentials" do
      {:ok, user} =
        UserFactory.build_param_map()
        |> Accounts.create_user()

      {:ok, authenticated_user} = Accounts.authenticate(user.email, "secret")
      assert authenticated_user.email == user.email
    end

    test "throws an error with incorrect credentials" do
      {:ok, user} =
        UserFactory.build_param_map()
        |> Accounts.create_user()

      assert {:error, "No Matching account found."} =
               Accounts.authenticate(user.email, "wrongpassword")
    end
  end
end
