defmodule PaymentServer.WalletTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServer.Wallets
  alias PaymentServer.Accounts
  alias PaymentServer.Wallets.Currency
  alias PaymentServer.{WalletFactory, UserFactory}

  setup [:setup_account]

  defp setup_account(context) do
    {:ok, user} = UserFactory.build_param_map() |> Accounts.create_user()
    Map.put(context, :user, user)
  end

  describe "create/1" do
    test "creates a currency with valid data", %{user: user} do
      valid_attrs = WalletFactory.build_param_map(%{user_id: user.id})
      assert {:ok, %Currency{} = currency} = Wallets.create(valid_attrs)
      assert currency.type == valid_attrs.type
    end

    test "returns error changeset with invalid data" do
      invalid_attrs = %{"type" => nil}
      assert {:error, %Ecto.Changeset{}} = Wallets.create(invalid_attrs)
    end
  end

  describe "update/2" do
    test "updates the currency with valid data", %{user: user} do
      currency_attrs = WalletFactory.build_param_map(%{user_id: user.id})
      {:ok, currency} = Wallets.create(currency_attrs)

      update_attrs = Map.put(%{currency_attrs | type: "EUR"}, :id, currency.id)
      assert {:ok, %Currency{} = updated_currency} = Wallets.update(update_attrs)
      assert updated_currency.type == "EUR"
    end

    test "returns error changeset with invalid data", %{user: user} do
      currency_attrs = WalletFactory.build_param_map(%{user_id: user.id})
      {:ok, currency} = Wallets.create(currency_attrs)

      invalid_attrs = Map.put(%{currency_attrs | type: 100}, :id, currency.id)
      assert {:error, %Ecto.Changeset{}} = Wallets.update(invalid_attrs)
    end
  end

  describe "delete/1" do
    test "deletes the currency", %{user: user} do
      currency_attrs = WalletFactory.build_param_map(%{user_id: user.id})
      {:ok, currency} = Wallets.create(currency_attrs)

      assert {:ok, %Currency{}} = Wallets.delete(currency)
      assert Wallets.get_by_id(currency.id) == nil
    end
  end

  describe "get_by_id/1" do
    test "returns the currency with the given id", %{user: user} do
      currency_attrs = WalletFactory.build_param_map(%{user_id: user.id})
      {:ok, currency} = Wallets.create(currency_attrs)

      found_currency = Wallets.get_by_id(currency.id)
      assert found_currency.type == currency.type
    end

    test "returns nil if the currency does not exist" do
      assert Wallets.get_by_id(-1) == nil
    end
  end

  describe "get_all/1" do
    test "returns all currencies for the given user id", %{user: user} do
      currency1_attrs = WalletFactory.build_param_map(%{user_id: user.id})
      {:ok, currency1} = Wallets.create(currency1_attrs)

      currency2_attrs = WalletFactory.build_param_map(%{user_id: user.id, type: "EUR"})
      {:ok, currency2} = Wallets.create(currency2_attrs)

      currencies = Wallets.get_all(user.id)
      assert length(currencies) == 2
      assert Enum.any?(currencies, fn currency -> currency.type == currency1.type end)
      assert Enum.any?(currencies, fn currency -> currency.type == currency2.type end)
    end
  end
end
