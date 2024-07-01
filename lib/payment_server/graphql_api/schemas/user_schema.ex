defmodule PaymentServer.GraphqlApi.Schemas.UserSchema do
  use Absinthe.Schema.Notation

  alias PaymentServer.GraphqlApi.Resolvers
  alias PaymentServer.GraphqlApi.Types

  # Types
  import_types(Types.UserType)
  import_types(Types.SessionType)

  object :user_queries do

    @desc "Get a list of all users"
    field :get_all_users, list_of(:user_type) do
      resolve(&Resolvers.UserResolver.users/3)
    end

    @desc "Get a user"
    field :get_a_user, :user_type do
      resolve(&Resolvers.UserResolver.get_user/3)
    end
  end

  object :user_mutations do

    @desc "Register a user"
    field :register_user, type: :user_type do
      arg(:input, non_null(:user_input_type))
      resolve(&Resolvers.UserResolver.create_user/3)
    end

    @desc "Sign a user in"
    field :sign_in, type: :session do
      arg(:input, non_null(:session_input))
      resolve(&Resolvers.UserResolver.sign_in/3)
    end

    @desc "Update a user"
    field :update_user, type: :user_type do
      arg(:input, non_null(:user_update_type))
      resolve(&Resolvers.UserResolver.update_user/3)
    end

    @desc "Delete a user"
    field :delete_user, type: :delete_response_type do
      resolve(&Resolvers.UserResolver.delete_user/3)
    end
  end
end
