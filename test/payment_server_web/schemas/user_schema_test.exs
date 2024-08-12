defmodule PaymentServerWeb.Schemas.UserSchemaTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServerWeb.Schema
  alias PaymentServer.{Accounts, UserFactory}

  @authentication_mutation """
    mutation signIn($email: String!, $password: String!) {
      signIn(email: $email, password: $password) {
        token
      }
    }
  """
  @registration_mutation """
  mutation($input: UserInputType!) {
    registerUser(input: $input) {
      id
      email
    }
  }
  """
  @all_users_query """
  query {
    getAllUsers {
      id
    }
  }
  """
  @get_a_user_query """
  query {
    getAUser {
      id
      firstName
    }
  }
  """
  @delete_user_mutation """
  mutation {
    deleteUser {
      message
    }
  }
  """
  @update_user_mutation """
  mutation updateUser($input: UserUpdateType!) {
    updateUser(input: $input) {
      id
      firstName
    }
  }
  """
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

  describe "@User:" do
    setup [:setup_account]

    test "a user can sign in" do
      assert {:ok, %{data: %{"signIn" => data}}} = Absinthe.run(@authentication_mutation, Schema, variables: %{
        "email"=> "user@example.com",
        "password"=> "secret"
      })
      assert Map.has_key?(data, "token") === true
    end

    test "a user cannot sign in with incorrect credentials" do
      assert {:ok, %{errors: errors}} = Absinthe.run(@authentication_mutation, Schema, variables: %{
        "email"=> "user1@example.com",
        "password"=> "secret"
      })
      assert List.first(errors).message === "Signin failed!"
    end

    test "a user can be registered" do
      assert {:ok, %{data: %{"registerUser"=> result}}} = Absinthe.run(@registration_mutation, Schema,
        variables: %{
          "input" => @valid_user_params
        }
      )
      assert result["email"] == @valid_user_params["email"]
    end

    test "a user cannot be registered with invalid data" do
      assert {:ok, %{errors: errors}} = Absinthe.run(@registration_mutation, Schema, variables: %{
        "input" => %{@valid_user_params | "password_confirmation" => "random"}
      })

      assert List.first(errors).message === "User creation failed!"
    end

    test "a user can get all users", %{user: user} do
      assert {:ok, %{data: %{"getAllUsers" => data}}} = Absinthe.run(@all_users_query, Schema, context: %{
        current_user: user
      })
      assert String.to_integer(List.first(data)["id"]) === user.id
    end

    test "a user cannot get all users without being authenticated" do
      make_unathenticated_request(@all_users_query)
    end

    test "a user cannot get a user's information without being authenticated" do
      make_unathenticated_request(@get_a_user_query)
    end

    test "a user can get his account information", %{user: user} do
      assert {:ok, %{data: %{"getAUser" => data}}} = Absinthe.run(@get_a_user_query, Schema, context: %{
        current_user: user
      })
      assert String.to_integer(data["id"]) === user.id
      assert data["firstName"] === user.first_name
    end

    test "a user can get another user's account information", %{user: user} do
      query = """
      query getAUser($id: ID!) {
        getAUser(id: $id) {
          id
          firstName
        }
      }
      """

      {:ok, user2} = %{UserFactory.build_param_map() | email: "random@email.com"}
        |> Accounts.create_user()
      assert {:ok, %{data: %{"getAUser" => data}}} = Absinthe.run(query, Schema, [
        context: %{
          current_user: user
        },
        variables: %{
          "id" => user2.id
        }
      ])
      assert String.to_integer(data["id"]) === user2.id
      assert data["firstName"] === user2.first_name
    end

    test "a user cannot delete another user", %{user: user} do
      mutation = """
      mutation deleteUser($id: ID!) {
        deleteUser(id: $id) {
          message
        }
      }
      """
      mutation2 = """
      mutation deleteUser($email: String!) {
        deleteUser(email: $email) {
          message
        }
      }
      """

      assert {:ok, %{errors: errors}} = Absinthe.run(mutation, Schema, [
        context: %{
          current_user: user
        },
        variables: %{
          "id" => 100
        }
      ])
      assert String.contains? List.first(errors).message, "Unknown argument \"id\""
      assert {:ok, %{errors: errors}} = Absinthe.run(mutation2, Schema, [
        context: %{
          current_user: user
        },
        variables: %{
          "email" => "random@example.com"
        }
      ])
      assert String.contains? List.first(errors).message, "Unknown argument \"email\""
    end

    test "a user cannot delete his account while being unauthenticated" do
      make_unathenticated_request(@delete_user_mutation)
    end

    test "a user can delete his account", %{user: user} do
      assert {:ok, %{data: %{"getAllUsers" => all_users}}} = Absinthe.run(@all_users_query, Schema, context: %{
        current_user: user
      })
      assert length(all_users) === 1
      assert {:ok, %{data: _data}} = Absinthe.run(@delete_user_mutation, Schema, context: %{
        current_user: user
      })
      assert {:ok, %{data: %{"getAllUsers" => all_users}}} = Absinthe.run(@all_users_query, Schema, context: %{
        current_user: user
      })
      assert length(all_users) === 0
    end

    test "a user cannot update his account while being unauthenticated" do
      make_unathenticated_request(@update_user_mutation, %{
        "input" => @update_params
      })
    end

    test "a user can update his account", %{user: user} do
      assert {:ok, %{data: %{"updateUser" => updated_user}}} = Absinthe.run(@update_user_mutation, Schema, [
        context: %{
          current_user: user
        },
        variables: %{
          "input" => @update_params
        }
      ])
      assert updated_user["firstName"] === @update_params["first_name"]
    end
  end



  defp make_unathenticated_request(absinthe_doc, variables \\ %{}) do
    assert {:ok, %{errors: errors}} = Absinthe.run(absinthe_doc, Schema, variables: variables)
    assert List.first(errors).message === @authentication_error_msg
  end

  defp setup_account(context) do
    {:ok, user} = UserFactory.build_param_map() |> Accounts.create_user()
    Map.put(context, :user, user)
  end
end
