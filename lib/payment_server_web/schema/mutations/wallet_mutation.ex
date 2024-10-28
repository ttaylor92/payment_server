defmodule PaymentServerWeb.Schema.Mutations.WalletMutation do
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Resolvers.WalletResolver

  object :wallet_mutations do
    @desc "Create a user wallet"
    field :wallet_create, type: :wallet_type do
      arg :type, non_null(:string)
      resolve &WalletResolver.create_wallet/3
    end

    if Enum.member?([:dev, :test], Mix.env()) do
      @desc "Update a user wallet"
      field :wallet_update, type: :wallet_type do
        arg :input, non_null(:wallet_update_type)
        resolve &WalletResolver.update_wallet/3
      end
    end

    @desc "Process a wallet transfer request"
    field :process_transfer_request, type: :wallet_type do
      arg :input, non_null(:wallet_transfer_input_type)
      resolve &WalletResolver.process_transaction/3
    end

    if Mix.env() === :dev do
      @desc "Process a wallet conversion request"
      field :process_conversion_request, type: :wallet_type do
        arg :input, non_null(:wallet_convert_input_type)
        resolve &WalletResolver.process_wallet_conversion/3
      end
    end

    @desc "Delete a user wallet"
    field :wallet_delete, type: :delete_response_type do
      arg :id, non_null(:id)
      resolve &WalletResolver.delete_wallet/3
    end
  end
end
