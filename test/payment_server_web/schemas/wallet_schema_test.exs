defmodule PaymentServerWeb.Schemas.WalletSchemaTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServerWeb.Schema
  alias PaymentServer.{Accounts, Wallets, UserFactory, WalletFactory}

  describe "@wallet:" do
    setup [:setup_account]

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
    @all_wallets_query"""
    query {
      getWallets {
        id
        type
      }
    }
    """
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
    @authentication_error_msg "Unauthenticated!!!"

    test "a user can create a wallet", %{user: user} do
      assert {:ok, %{data: %{"createWallet" => data}}} = Absinthe.run(@create_wallet_mutation, Schema, [
        variables: %{
          "type" => "AUD"
        },
        context: %{
          current_user: user
        }
      ])

      assert data["type"] === "AUD"
      assert String.to_integer(data["user"]["id"]) === user.id
    end

    test "a user cannot create a wallet when unauthenticated" do
      make_unathenticated_request(@create_wallet_mutation, "createWallet", %{"type" => "AUD"})
    end

    # test "a user can get his wallet", %{user: user} do
    #   assert {:ok, %{data: %{"createWallet" => wallet}}} = Absinthe.run(@create_wallet_mutation, Schema, [
    #     variables: %{
    #       "type" => "AUD"
    #     },
    #     context: %{
    #       current_user: user
    #     }
    #   ])

    #   IO.inspect(wallet, label: "wallet result")

    #   assert {:ok, %{data: data, errors: errors}} = Absinthe.run(@wallet_query, Schema, [
    #     variables: %{
    #       "walletType" => "AUD"
    #     },
    #     context: %{
    #       current_user: user
    #     }
    #   ])
    #   IO.inspect(errors, label: "data result")

    #   assert String.to_integer(data["id"]) === wallet["id"]
    #   assert data["type"] === wallet["type"]
    #   assert String.to_integer(data["user"]["id"]) === user.id
    # end

    test "a user cannot get his wallet when unauthenticated" do
      make_unathenticated_request(@wallet_query, "getWallet", %{"walletType" => "USD"})
    end

    test "a user can get all of his wallets", %{user: user} do
      {:ok, wallet} = WalletFactory.build_param_map(%{user_id: user.id})
      |> Wallets.create()
      {:ok, wallet2} = WalletFactory.build_param_map(%{user_id: user.id, type: "RAN"})
      |> Wallets.create()

      assert {:ok, %{data: %{"getWallets" => data}}} = Absinthe.run(@all_wallets_query, Schema, context: %{
        current_user: user
      })
      assert length(data) === 2
      assert String.to_integer(List.first(data)["id"]) === wallet.id
      assert String.to_integer(List.last(data)["id"]) === wallet2.id
    end

    test "a user cannot get all his wallets when unauthenticated" do
      make_unathenticated_request(@all_wallets_query, "getWallets")
    end


  end

  defp make_unathenticated_request(absinthe_doc, key, variables \\ %{}) do
    assert {:ok, %{data: data, errors: errors}} = Absinthe.run(absinthe_doc, Schema, variables: variables)
    assert List.first(errors).message === @authentication_error_msg
    assert data[key] === nil
  end

  defp setup_account(context) do
    {:ok, user} = UserFactory.build_param_map() |> Accounts.create_user()
    Map.put(context, :user, user)
  end
end
