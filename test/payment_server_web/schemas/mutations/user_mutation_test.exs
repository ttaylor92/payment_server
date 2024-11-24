defmodule PaymentServerWeb.Schemas.UserSchemaTest do
  use PaymentServer.DataCase

  alias PaymentServerWeb.Schema
  alias PaymentServer.SchemasPg.{Accounts}
  alias PaymentServer.Support.{UserFactory}

  setup [:setup_account]

  @valid_user_params %{
    "first_name" => "John",
    "last_name" => "Doe",
    "email" => "john.doe@example.com",
    "password" => "secret123",
    "password_confirmation" => "secret123",
    "default_currency" => "USD"
  }
  @update_params %{"first_name" => "Jane"}
  @authentication_error_msg "Unauthenticated!!!"

  @authentication_mutation """
  mutation signIn($email: String!, $password: String!) {
    signIn(email: $email, password: $password) {
      token
    }
  }
  """
  @delete_user_mutation """
  mutation {
    userDelete {
      message
    }
  }
  """
  @update_user_mutation """
  mutation userUpdate($input: UserUpdateType!) {
    userUpdate(input: $input) {
      id
      firstName
    }
  }
  """
  @registration_mutation """
  mutation($input: UserInputType!) {
    userRegistration(input: $input) {
      id
      email
    }
  }
  """

  describe "@signIn:" do
    test "a user can sign in", %{user: user} do
      assert {:ok, %{data: %{"signIn" => data}}} =
               Absinthe.run(@authentication_mutation, Schema,
                 variables: %{
                   "email" => user.email,
                   "password" => "secret"
                 }
               )

      assert Map.has_key?(data, "token") === true
    end

    test "a user cannot sign in with incorrect credentials" do
      assert {:ok, %{errors: errors}} =
               Absinthe.run(@authentication_mutation, Schema,
                 variables: %{
                   "email" => "user1@example.com",
                   "password" => "secret"
                 }
               )

      assert List.first(errors).message === "Signin failed!"
    end
  end

  describe "@userUpdate:" do
    test "a user cannot update his account while being unauthenticated" do
      make_unathenticated_request(@update_user_mutation, %{
        "input" => @update_params
      })
    end

    test "a user can update his account", %{user: user} do
      assert {:ok, %{data: %{"userUpdate" => updated_user}}} =
               Absinthe.run(@update_user_mutation, Schema,
                 context: %{
                   current_user: user
                 },
                 variables: %{
                   "input" => @update_params
                 }
               )

      assert updated_user["firstName"] === @update_params["first_name"]
    end
  end

  describe "@userRegistration:" do
    test "a user can be registered" do
      assert {:ok, %{data: %{"userRegistration" => result}}} =
               Absinthe.run(@registration_mutation, Schema,
                 variables: %{
                   "input" => @valid_user_params
                 }
               )

      assert result["email"] == @valid_user_params["email"]
    end

    test "a user cannot be registered with invalid data" do
      assert {:ok, %{errors: errors}} =
               Absinthe.run(@registration_mutation, Schema,
                 variables: %{
                   "input" => %{@valid_user_params | "password_confirmation" => "random"}
                 }
               )

      assert List.first(errors).message === "User creation failed!"
    end
  end

  describe "@userDelete" do
    test "a user cannot delete his account while being unauthenticated" do
      make_unathenticated_request(@delete_user_mutation)
    end

    test "a user can delete his account", %{user: user} do
      all_users = Accounts.list_users()
      assert length(all_users) === 1

      assert {:ok, %{data: _data}} =
               Absinthe.run(@delete_user_mutation, Schema,
                 context: %{
                   current_user: user
                 }
               )

      all_users = Accounts.list_users()
      assert length(all_users) === 0
    end

    test "a user cannot delete another user", %{user: user} do
      mutation = """
      mutation userDelete($id: ID!) {
        userDelete(id: $id) {
          message
        }
      }
      """

      mutation2 = """
      mutation userDelete($email: String!) {
        userDelete(email: $email) {
          message
        }
      }
      """

      assert {:ok, %{errors: errors}} =
               Absinthe.run(mutation, Schema,
                 context: %{
                   current_user: user
                 },
                 variables: %{
                   "id" => 100
                 }
               )

      assert String.contains?(List.first(errors).message, "Unknown argument \"id\"")

      assert {:ok, %{errors: errors}} =
               Absinthe.run(mutation2, Schema,
                 context: %{
                   current_user: user
                 },
                 variables: %{
                   "email" => "random@example.com"
                 }
               )

      assert String.contains?(List.first(errors).message, "Unknown argument \"email\"")
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
