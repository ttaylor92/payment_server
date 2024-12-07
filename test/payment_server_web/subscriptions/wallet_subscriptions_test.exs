defmodule PaymentServerWeb.Subscriptions.WalletSubscriptionsTest do
  use PaymentServerWeb.SubscriptionCase
alias PaymentServer.Authentication
  use PaymentServer.DataCase

  alias PaymentServer.Support.{WalletFactory, UserFactory}
  alias PaymentServer.SchemasPg.{Accounts, Wallets}
  alias Utils.AuthToken

  setup [:setup_account, :setup_token]

  describe "Subscriptions" do
    test "a user cannot subscribe/connect without being authenticated" do
      assert {:error, _message} = Phoenix.ChannelTest.connect(PaymentServerWeb.UserSocket, %{})
    end
  end

  describe "@Currency" do
    @currency_subscription """
    subscription currencyUpdate($currency: String!) {
      currencyUpdate(currency: $currency) {
        amount
      }
    }
    """
    test "a user can get updates from the currency_update subscription", %{
      token: token,
      user: user
    } do
      socket = setup_user_socket(token)

      # Setup a socket and join the channel
      ref = push_doc(socket, @currency_subscription,
        variables: %{"currency" => "AUD"},
        context: %{
          current_user: user
        }
      )
      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      assert_push "subscription:data", data, :timer.seconds(12)

      assert %{
               subscriptionId: ^subscription_id,
               result: %{
                 data: %{
                   "currencyUpdate" => %{
                     "amount" => _amount
                   }
                 }
               }
             } = data
    end

    @all_currencies_subscription """
    subscription allCurrenciesUpdate {
      allCurrenciesUpdate {
        rate
        currency_to
        currency_from
      }
    }
    """
    test "a user can get updates for all_currencies_update subscription", %{
      token: token,
      user: user
    } do
      socket = setup_user_socket(token)

      # Setup a socket and join the channel
      ref = push_doc(socket, @all_currencies_subscription, context: %{
        current_user: user
      })
      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      assert_push "subscription:data", data, :timer.seconds(12)

      assert %{
               subscriptionId: ^subscription_id,
               result: %{
                 data: %{
                   "allCurrenciesUpdate" => allCurrenciesUpdateData
                 }
               }
             } = data

      assert length(allCurrenciesUpdateData) > 0
    end
  end

  @total_worth_subscription """
  subscription totalWorthUpdate {
    totalWorthUpdate {
      amount
      default_currency
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
  describe "@Wallet" do
    test "total_worth_update subscription is triggered after a wallet transfer", %{
      user: user,
      token: token
    } do
      # Setup users and wallets
      {:ok, wallet} = WalletFactory.build_param_map(%{user_id: user.id}) |> Wallets.create()
      {:ok, _wallet} = Wallets.update(wallet, %{amount: 100})

      {:ok, receiver} =
        UserFactory.build_param_map(%{email: "mail@exam.com"}) |> Accounts.create_user()

      {:ok, _receiver_wallet} =
        WalletFactory.build_param_map(%{user_id: receiver.id}) |> Wallets.create()

      {:ok, updated_user} = Accounts.get_user(user.id, preload: :curriences)

      socket = setup_user_socket(token)

      # Setup a socket and join the channel
      ref = push_doc(socket, @total_worth_subscription, context: %{
        current_user: updated_user
      })
      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      # Trigger mutation
      requested_amount = 50.00

      ref =
        push_doc(socket, @wallet_transfer_mutation,
          context: %{
            current_user: updated_user
          },
          variables: %{
            "input" => %{
              "requested_amount" => requested_amount,
              "user_id" => receiver.id,
              "wallet_type" => wallet.type
            }
          }
        )

      assert_reply ref, :ok, _reply

      assert_push "subscription:data", data

      assert %{
               subscriptionId: ^subscription_id,
               result: %{
                 data: %{
                   "totalWorthUpdate" => %{
                     "amount" => ^requested_amount
                   }
                 }
               }
             } = data
    end
  end

  defp setup_account(context) do
    {:ok, user} = UserFactory.build_param_map() |> Accounts.create_user()
    Map.put(context, :user, user)
  end

  defp setup_token(context) do
    {:ok, user} = Authentication.authenticate_user(context.user.email, context.user.password)
    token = AuthToken.create(user)
    Map.put(context, :token, token)
  end

  defp setup_user_socket(token) do
    {:ok, socket} =
      Phoenix.ChannelTest.connect(PaymentServerWeb.UserSocket, %{
        "Authorization" => "Bearer " <> token
      })

    {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)

    socket
  end
end
