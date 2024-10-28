defmodule PaymentServerWeb.Schema.Mutations.UserMutation do
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Resolvers.UserResolver

  object :user_mutations do
    @desc "Register a user"
    field :user_registration, type: :user_type do
      arg :input, non_null(:user_input_type)
      resolve &UserResolver.create_user/3
    end

    @desc "Sign a user in"
    field :sign_in, type: :session do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      resolve &UserResolver.sign_in/3
    end

    @desc "Update a user"
    field :user_update, type: :user_type do
      arg :input, non_null(:user_update_type)
      resolve &UserResolver.update_user/3
    end

    @desc "Delete a user"
    field :user_delete, type: :delete_response_type do
      resolve &UserResolver.delete_user/3
    end
  end
end
