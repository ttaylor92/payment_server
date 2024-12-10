defmodule PaymentServerWeb.Schemas.Queries.UserQueryTest do
  use PaymentServer.DataCase

  alias PaymentServerWeb.Schema
  alias PaymentServer.SchemasPg.Accounts
  alias PaymentServer.Support.UserFactory

  setup [:setup_account]

  @authentication_error_msg "Unauthenticated!!!"
  @all_users_query """
  query {
    users {
      id
    }
  }
  """
  @get_a_user_query """
  query {
    user {
      id
      firstName
    }
  }
  """
  describe "@users:" do
    test "a user can get all users", %{user: user} do
      assert {:ok, %{data: %{"users" => data}}} =
               Absinthe.run(@all_users_query, Schema,
                 context: %{
                   current_user: user
                 }
               )

      assert String.to_integer(List.first(data)["id"]) === user.id
    end

    test "a user cannot get all users without being authenticated" do
      make_unathenticated_request(@all_users_query)
    end
  end

  describe "@user: " do
    test "a user cannot get a user's information without being authenticated" do
      make_unathenticated_request(@get_a_user_query)
    end

    test "a user can get his account information", %{user: user} do
      assert {:ok, %{data: %{"user" => data}}} =
               Absinthe.run(@get_a_user_query, Schema,
                 context: %{
                   current_user: user
                 }
               )

      assert String.to_integer(data["id"]) === user.id
      assert data["firstName"] === user.first_name
    end

    test "a user can get another user's account information", %{user: user} do
      query = """
      query user($id: ID!) {
        user(id: $id) {
          id
          firstName
        }
      }
      """

      {:ok, user2} =
        Accounts.create_user(%{UserFactory.build_param_map() | email: "random@email.com"})

      assert {:ok, %{data: %{"user" => data}}} =
               Absinthe.run(query, Schema,
                 context: %{
                   current_user: user
                 },
                 variables: %{
                   "id" => user2.id
                 }
               )

      assert String.to_integer(data["id"]) === user2.id
      assert data["firstName"] === user2.first_name
    end
  end

  defp make_unathenticated_request(absinthe_doc, variables \\ %{}) do
    assert {:ok, %{errors: errors}} = Absinthe.run(absinthe_doc, Schema, variables: variables)
    assert List.first(errors).message === @authentication_error_msg
  end

  defp setup_account(context) do
    {:ok, user} = Accounts.create_user(UserFactory.build_param_map())
    Map.put(context, :user, user)
  end
end
