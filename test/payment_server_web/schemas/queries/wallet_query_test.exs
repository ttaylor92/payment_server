defmodule PaymentServerWeb.Schema.Queries.WalletQueryTest do
  use PaymentServer.DataCase

  alias PaymentServerWeb.Schema
  alias PaymentServer.SchemasPg.{Accounts, Wallets}
  alias PaymentServer.Support.{UserFactory, WalletFactory}

  setup [:setup_account]

  @authentication_error_msg "Unauthenticated!!!"

  @wallet_query """
    query wallet($walletType: String!) {
      wallet(walletType: $walletType) {
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
    wallets {
      id
      type
    }
  }
  """
  @currencies_query """
    query currencies {
      currencies {
        label
        value
      }
    }
  """

  describe "@Wallet - Get Wallet/s:" do
    test "a user can get his wallet", %{user: user} do
      {:ok, wallet} = Wallets.create(WalletFactory.build_param_map(%{user_id: user.id}))
      user_id = Integer.to_string(user.id)
      wallet_id = Integer.to_string(wallet.id)

      assert {:ok, %{data: %{"wallet" => %{
                "id" => ^wallet_id,
                "type" => "USD",
                "user" => %{
                  "id" => ^user_id
                }
              }}}} =
               Absinthe.run(@wallet_query, Schema,
                 variables: %{
                   "walletType" => "USD"
                 },
                 context: %{
                   current_user: user
                 }
               )
    end

    test "a user cannot get his wallet when unauthenticated" do
      make_unathenticated_request(@wallet_query, "wallet", %{"walletType" => "USD"})
    end

    test "a user can get all of his wallets", %{user: user} do
      {:ok, wallet} = %{user_id: user.id}
        |> WalletFactory.build_param_map()
        |> Wallets.create()

      {:ok, wallet2} = %{user_id: user.id, type: "RAN"}
        |> WalletFactory.build_param_map()
        |> Wallets.create()

      assert {:ok, %{data: %{"wallets" => data}}} =
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

  describe "@Wallet - Currencies" do
    test "a user can get the list of accepted currencies", %{user: user} do
      assert {:ok, %{data: %{"currencies" => data}}} =
               Absinthe.run(@currencies_query, Schema,
                 context: %{
                   current_user: user
                 }
               )

      expected_result = %{"value" => "AED", "label" => "United Arab Emirates Dirham"}

      assert List.first(data) === expected_result
    end

    test "a user cannot get the list of accepted currencies when unauthenticated" do
      make_unathenticated_request(@currencies_query, "currencies")
    end
  end

  defp make_unathenticated_request(absinthe_doc, key, variables \\ %{}) do
    assert {:ok, %{data: data, errors: errors}} =
             Absinthe.run(absinthe_doc, Schema, variables: variables)

    assert List.first(errors).message === @authentication_error_msg
    assert data[key] === nil
  end

  defp setup_account(context) do
    {:ok, user} = Accounts.create_user(UserFactory.build_param_map())
    Map.put(context, :user, user)
  end
end
