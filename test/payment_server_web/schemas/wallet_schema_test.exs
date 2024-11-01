defmodule PaymentServerWeb.Schemas.WalletSchemaTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServerWeb.Schema
  alias PaymentServer.{Accounts, Wallets}
  alias PaymentServer.Support.{UserFactory, WalletFactory}

  setup [:setup_account]

  @authentication_error_msg "Unauthenticated!!!"

  @create_wallet_mutation """
  mutation createWallet($type: String!) {
    createWallet(type: $type) {
      id
      type
      user {
        id
      }
    }
  }
  """
  describe "@Wallet - Wallet Creation" do
    test "a user can create a wallet", %{user: user} do
      assert {:ok, %{data: %{"createWallet" => data}}} =
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
      make_unathenticated_request(@create_wallet_mutation, "createWallet", %{"type" => "AUD"})
    end
  end

  @wallet_query """
    query getWallet($walletType: String!) {
      getWallet(walletType: $walletType) {
        id
        type
        user {
          id
          firstName
        }
      }
    }
  """
  @all_wallets_query """
  query {
    getWallets {
      id
      type
    }
  }
  """
  describe "@Wallet - Get Wallet/s:" do
    test "a user can get his wallet", %{user: user} do
      assert {:ok, %{data: %{"createWallet" => wallet}}} =
               Absinthe.run(@create_wallet_mutation, Schema,
                 variables: %{
                   "type" => "AUD"
                 },
                 context: %{
                   current_user: user
                 }
               )

      updated_user = Accounts.get_user(user.id)

      assert {:ok, %{data: %{"getWallet" => data}}} =
               Absinthe.run(@wallet_query, Schema,
                 variables: %{
                   "walletType" => "AUD"
                 },
                 context: %{
                   current_user: updated_user
                 }
               )

      assert data["id"] === wallet["id"]
      assert data["type"] === wallet["type"]
      assert String.to_integer(data["user"]["id"]) === user.id
    end

    test "a user cannot get his wallet when unauthenticated" do
      make_unathenticated_request(@wallet_query, "getWallet", %{"walletType" => "USD"})
    end

    test "a user can get all of his wallets", %{user: user} do
      {:ok, wallet} =
        WalletFactory.build_param_map(%{user_id: user.id})
        |> Wallets.create()

      {:ok, wallet2} =
        WalletFactory.build_param_map(%{user_id: user.id, type: "RAN"})
        |> Wallets.create()

      assert {:ok, %{data: %{"getWallets" => data}}} =
               Absinthe.run(@all_wallets_query, Schema,
                 context: %{
                   current_user: user
                 }
               )

      assert length(data) === 2
      assert String.to_integer(List.first(data)["id"]) === wallet.id
      assert String.to_integer(List.last(data)["id"]) === wallet2.id
    end

    test "a user cannot get all his wallets when unauthenticated" do
      make_unathenticated_request(@all_wallets_query, "getWallets")
    end
  end

  @currencies_query """
    query getCurrencies {
      getCurrencies {
        label
        value
      }
    }
  """
  describe "@Wallet - Currencies" do
    test "a user can get the list of accepted currencies", %{user: user} do
      assert {:ok, %{data: %{"getCurrencies" => data}}} =
               Absinthe.run(@currencies_query, Schema,
                 context: %{
                   current_user: user
                 }
               )

      expected_result = %{"value" => "AED", "label" => "United Arab Emirates Dirham"}

      assert List.first(data) == expected_result
    end

    test "a user cannot get the list of accepted currencies when unauthenticated" do
      make_unathenticated_request(@currencies_query, "getCurrencies")
    end
  end

  @delete_wallet_mutation """
  mutation deleteWallet($id: ID!) {
    deleteWallet(id: $id) {
      message
    }
  }
  """
  describe "@Wallet - Deletion:" do
    test "a user can delete his wallet", %{user: user} do
      {:ok, wallet} =
        WalletFactory.build_param_map(%{user_id: user.id})
        |> Wallets.create()

      updated_user = Accounts.get_user(user.id)

      {:ok, %{data: %{"deleteWallet" => data}}} =
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
      make_unathenticated_request(@delete_wallet_mutation, "deleteWallet", %{"id" => 20})
    end
  end

  @wallet_transfer_mutation """
  mutation processTransferRequest($input: WalletTransferInputType!) {
    processTransferRequest(input: $input) {
      id
      amount
    }
  }
  """
  describe "@Wallet - Transfer:" do
    test "a user can transfer an amount to another user of the same currency", %{user: user} do
      {:ok, wallet} =
        WalletFactory.build_param_map(%{user_id: user.id})
        |> Wallets.create()

      {:ok, receiver} =
        UserFactory.build_param_map(%{email: "mail@exam.com"}) |> Accounts.create_user()

      {:ok, receiver_wallet} =
        WalletFactory.build_param_map(%{user_id: receiver.id})
        |> Wallets.create()

      updated_user_with_wallet = Accounts.get_user(user.id)

      update_mutation = """
      mutation updateWallet($input: WalletUpdateType!) {
        updateWallet(input: $input) {
          amount
        }
      }
      """

      {:ok, %{data: %{"updateWallet" => wallet_update_response}}} =
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

      updated_user_with_bal = Accounts.get_user(user.id)

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

      updated_receiver_wallet = Wallets.get_by_id(receiver_wallet.id)
      assert updated_receiver_wallet.amount === 50.00

      updated_wallet = Wallets.get_by_id(wallet.id)
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

      updated_user_with_wallet = Accounts.get_user(user.id)

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

  defp make_unathenticated_request(absinthe_doc, key, variables \\ %{}) do
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
