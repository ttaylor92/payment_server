defmodule PaymentServer.WalletsTest do
  use PaymentServer.DataCase

  alias PaymentServer.SchemasPg.Wallets
  alias PaymentServer.SchemasPg.Accounts
  alias PaymentServer.SchemasPg.Wallets.Currency
  alias PaymentServer.Support.{WalletFactory, UserFactory}

  setup [:setup_account]

  describe "create/1" do
    test "creates a currency with valid data", %{user: user} do
      valid_attrs = WalletFactory.build_param_map(%{user_id: user.id})
      assert {:ok, %Currency{} = currency} = Wallets.create(valid_attrs)
      assert currency.type === valid_attrs.type
    end

    test "returns error changeset with invalid data" do
      invalid_attrs = %{type: nil}
      assert {:error, %Ecto.Changeset{}} = Wallets.create(invalid_attrs)
    end
  end

  describe "update/2" do
    test "updates the currency with valid data", %{user: user} do
      currency_attrs = WalletFactory.build_param_map(%{user_id: user.id})
      {:ok, currency} = Wallets.create(currency_attrs)

      assert {:ok, %Currency{} = updated_currency} = Wallets.update(currency, %{type: "EUR"})
      assert updated_currency.type === "EUR"
    end

    test "returns error changeset with invalid data", %{user: user} do
      currency_attrs = WalletFactory.build_param_map(%{user_id: user.id})
      {:ok, currency} = Wallets.create(currency_attrs)

      assert {:error, %Ecto.Changeset{}} = Wallets.update(currency, %{type: 100})
    end
  end

  describe "delete/1" do
    test "deletes the currency", %{user: user} do
      currency_attrs = WalletFactory.build_param_map(%{user_id: user.id})
      {:ok, currency} = Wallets.create(currency_attrs)

      assert {:ok, %Currency{}} = Wallets.delete(currency)
      assert {:error, %ErrorMessage{code: :not_found, message: "no records found", details: _}} = Wallets.get_by_id(currency.id)
    end
  end

  describe "get_by_id/1" do
    test "returns the currency with the given id", %{user: user} do
      currency_attrs = WalletFactory.build_param_map(%{user_id: user.id})
      {:ok, currency} = Wallets.create(currency_attrs)

      {:ok, found_currency} = Wallets.get_by_id(currency.id)
      assert found_currency.type === currency.type
    end

    test "returns error if the currency does not exist" do
      assert {:error, %ErrorMessage{code: :not_found, message: "no records found", details: _}} = Wallets.get_by_id(-1)
    end
  end

  describe "get_all/1" do
    test "returns all currencies for the given user id", %{user: user} do
      currency1_attrs = WalletFactory.build_param_map(%{user_id: user.id})
      {:ok, currency1} = Wallets.create(currency1_attrs)

      currency2_attrs = WalletFactory.build_param_map(%{user_id: user.id, type: "EUR"})
      {:ok, currency2} = Wallets.create(currency2_attrs)

      currencies = Wallets.get_all(%{user_id: user.id})
      assert length(currencies) === 2
      assert Enum.any?(currencies, fn currency -> currency.type === currency1.type end)
      assert Enum.any?(currencies, fn currency -> currency.type === currency2.type end)
    end
  end

  defp setup_account(context) do
    {:ok, user} = Accounts.create_user(UserFactory.build_param_map())
    Map.put(context, :user, user)
  end
end
