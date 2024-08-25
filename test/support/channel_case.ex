defmodule PaymentServerWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      import Phoenix.ChannelTest
      import PaymentServerWeb.ChannelCase

      # The default endpoint for test
      @endpoint PaymentServerWeb.Endpoint
    end
  end
end
