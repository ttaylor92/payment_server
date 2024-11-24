defmodule PaymentServerWeb.Schemas.WalletSchemaTest do
  use PaymentServer.DataCase

  alias PaymentServerWeb.Schema
  alias PaymentServer.SchemasPg.{Accounts, Wallets}
  alias PaymentServer.Support.{UserFactory, WalletFactory}

  setup [:setup_account]

  @authentication_error_msg "Unauthenticated!!!"

  @create_wallet_mutation """
  mutation walletCreate($type: String!) {
    walletCreate(type: $type) {
      id
      type
      user {
        id
      }
    }
  }
  """
  @delete_wallet_mutation """
  mutation walletDelete($id: ID!) {
    walletDelete(id: $id) {
      message
    }
  }
  """
  @wallet_transfer_mutation """
  mutation processTransferRequest($input: WalletTransferInputType!) {
    processTransferRequest(input: $input) {
      id
      amount
    }
  }
  """

  describe "@walletCreate: " do
    test "a user can create a wallet", %{user: user} do
      assert {:ok, %{data: %{"walletCreate" => data}}} =
               Absinthe.run(@create_wallet_mutation, Schema,
                 variables: %{
                   "type" => "AUD"
                 },
                 context: %{
                   current_user: user
                 }
               )

      assert data["type"] === "AUD"
      assert String.to_integer(data["user"]["id"]) === user.id
    end

    test "a user cannot create a wallet when unauthenticated" do
      make_unathenticated_request(@create_wallet_mutation, "walletCreate", %{"type" => "AUD"})
    end
  end


  describe "@walletDelete: " do
    test "a user can delete his wallet", %{user: user} do
      {:ok, wallet} =
        WalletFactory.build_param_map(%{user_id: user.id})
        |> Wallets.create()

      {:ok, updated_user} = Accounts.get_user(user.id, preload: :curriences)

      {:ok, %{data: %{"walletDelete" => data}}} =
        Absinthe.run(@delete_wallet_mutation, Schema,
          context: %{
            current_user: updated_user
          },
          variables: %{
            "id" => wallet.id
          }
        )

      assert data["message"] === "Wallet deleted."
    end

    test "a user cannot delete a wallet while being unauthenticated" do
      make_unathenticated_request(@delete_wallet_mutation, "walletDelete", %{"id" => 20})
    end
  end

  describe "@processTransferRequest: " do
    test "a user can transfer an amount to another user of the same currency", %{user: user} do
      {:ok, wallet} =
        WalletFactory.build_param_map(%{user_id: user.id})
        |> Wallets.create()

      {:ok, receiver} =
        UserFactory.build_param_map(%{email: "mail@exam.com"}) |> Accounts.create_user()

      {:ok, receiver_wallet} =
        WalletFactory.build_param_map(%{user_id: receiver.id})
        |> Wallets.create()

      {:ok, updated_user_with_wallet} = Accounts.get_user(user.id, preload: :curriences)

      update_mutation = """
      mutation walletUpdate($input: WalletUpdateType!) {
        walletUpdate(input: $input) {
          amount
        }
      }
      """

      {:ok, %{data: %{"walletUpdate" => wallet_update_response}}} =
        Absinthe.run(update_mutation, Schema,
          variables: %{
            "input" => %{
              "id" => wallet.id,
              "amount" => 100.00
            }
          },
          context: %{
            current_user: updated_user_with_wallet
          }
        )

      assert wallet_update_response["amount"] === 100.00

      {:ok, updated_user_with_bal} = Accounts.get_user(user.id, preload: :curriences)

      assert {:ok, %{data: %{"processTransferRequest" => _data}}} =
               Absinthe.run(@wallet_transfer_mutation, Schema,
                 variables: %{
                   "input" => %{
                     "requested_amount" => 50.00,
                     "user_id" => receiver.id,
                     "wallet_type" => "USD"
                   }
                 },
                 context: %{
                   current_user: updated_user_with_bal
                 }
               )

      {:ok, updated_receiver_wallet} = Wallets.get_by_id(receiver_wallet.id)
      assert updated_receiver_wallet.amount === 10050.00

      {:ok, updated_wallet} = Wallets.get_by_id(wallet.id)
      assert updated_wallet.amount === 50.00
    end

    test "a user cannot transfer an amount to another user if they dont have the same currency",
         %{user: user} do
      {:ok, receiver} =
        UserFactory.build_param_map(%{email: "mail@exam.com"}) |> Accounts.create_user()

      {:ok, _receiver_wallet} =
        WalletFactory.build_param_map(%{user_id: receiver.id, type: "AUD"})
        |> Wallets.create()

      {:ok, _wallet} =
        WalletFactory.build_param_map(%{user_id: user.id})
        |> Wallets.create()

      {:ok, updated_user_with_wallet} = Accounts.get_user(user.id)

      assert {:ok, %{errors: errors}} =
               Absinthe.run(@wallet_transfer_mutation, Schema,
                 variables: %{
                   "input" => %{
                     "requested_amount" => 50.00,
                     "user_id" => receiver.id,
                     "wallet_type" => "USD"
                   }
                 },
                 context: %{
                   current_user: updated_user_with_wallet
                 }
               )

      assert List.first(errors).message ===
               "Recipient or sender has no wallet with matching currency found."
    end

    test "a user cannot transfer an amount while being unauthenticated" do
      make_unathenticated_request(@wallet_transfer_mutation, "processTransferRequest", %{
        "input" => %{
          "userId" => 12,
          "walletType" => "USD",
          "requestedAmount" => 1000
        }
      })
    end
  end

  defp make_unathenticated_request(absinthe_doc, key, variables) do
    assert {:ok, %{data: data, errors: errors}} =
             Absinthe.run(absinthe_doc, Schema, variables: variables)

    assert List.first(errors).message === @authentication_error_msg
    assert data[key] === nil
  end

  defp setup_account(context) do
    {:ok, user} = UserFactory.build_param_map() |> Accounts.create_user()
    Map.put(context, :user, user)
  end
end
