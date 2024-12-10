defmodule PaymentServer.SchemasPg.AccountsTest do
  use PaymentServer.DataCase

  alias PaymentServer.SchemasPg.Accounts
  alias PaymentServer.SchemasPg.Accounts.User
  alias PaymentServer.Support.UserFactory

  describe "list_users/2" do
    test "returns all users" do
      Accounts.create_user(UserFactory.build_param_map())
      users_fetched = Accounts.list_users()

      assert Enum.empty?(users_fetched) === false
    end

    test "lists users before given argument, before" do
      _user1 = Accounts.create_user(UserFactory.build_param_map())
      {:ok, user2} = Accounts.create_user(UserFactory.build_param_map())
      users_fetched = Accounts.list_users(%{before: user2.id})

      assert length(users_fetched) === 1
    end

    test "lists users after given argument, after" do
      {:ok, user1} = Accounts.create_user(UserFactory.build_param_map())
      _user2 = Accounts.create_user(UserFactory.build_param_map())
      users_fetched = Accounts.list_users(%{after: user1.id})

      assert length(users_fetched) === 1
    end

    test "lists based on given argument, first" do
      _user1 = Accounts.create_user(UserFactory.build_param_map())
      _user2 = Accounts.create_user(UserFactory.build_param_map())
      _user3 = Accounts.create_user(UserFactory.build_param_map())
      users_fetched = Accounts.list_users(%{first: 1})

      assert length(users_fetched) === 1
    end
  end

  describe "get_user/1" do
    test "returns the user with the given id" do
      {:ok, user} = Accounts.create_user(UserFactory.build_param_map())
      {:ok, user_fetched} = Accounts.get_user(user.id)

      assert user_fetched.email === user.email
    end

    test "raises Ecto.NoResultsError if the user does not exist" do
      assert {:error, error} = Accounts.get_user(-1)
      assert error.code === :not_found
    end
  end

  describe "create_user/1" do
    test "creates a user with valid data" do
      valid_attrs = UserFactory.build_param_map()
      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.email === valid_attrs.email
    end

    test "returns error changeset with invalid data" do
      invalid_attrs = %{UserFactory.build_param_map() | email: "email.com"}
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(invalid_attrs)
    end
  end

  describe "update_user/2" do
    test "updates the user with valid data" do
      {:ok, user} = Accounts.create_user(UserFactory.build_param_map())

      updated_user_req =
        Map.put(%{UserFactory.build_param_map() | first_name: "new_first_name"}, :id, user.id)

      assert {:ok, updated_user} = Accounts.update_user(user, updated_user_req)
      assert updated_user.first_name === "new_first_name"
    end

    test "returns error changeset with invalid data" do
      {:ok, user} = Accounts.create_user(UserFactory.build_param_map())
      updated_user_req = %{UserFactory.build_param_map() | email: "email.com"}

      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, updated_user_req)
    end
  end

  describe "delete_user/1" do
    test "deletes the user" do
      {:ok, user} = Accounts.create_user(UserFactory.build_param_map())
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert {:error, error} = Accounts.get_user(user.id)
      assert error.code === :not_found
    end
  end
end
