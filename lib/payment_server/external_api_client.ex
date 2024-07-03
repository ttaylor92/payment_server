defmodule PaymentServer.ExternalApiClient do
  use HTTPoison.Base

  @moduledoc """
  A client module for interacting with an external API.
  """

  @api_base_url "https://api.example.com"

  @doc """
  Fetches a resource by its ID.

  ## Parameters

    - `resource_id`: The ID of the resource to fetch.

  ## Examples

      iex> MyApp.ExternalApiClient.get_resource("123")
      {:ok, %{"id" => "123", "name" => "Resource Name"}}

  """
  def get_resource(resource_id) do
    url = "#{@api_base_url}/resources/#{resource_id}"
    case get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code}} when status_code in 400..499 ->
        {:error, "Client error: #{status_code}"}

      {:ok, %HTTPoison.Response{status_code: status_code}} when status_code in 500..599 ->
        {:error, "Server error: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Creates a new resource with the provided parameters.

  ## Parameters

    - `resource_params`: A map containing the parameters of the resource to create.

  ## Examples

      iex> MyApp.ExternalApiClient.post_resource(%{"name" => "New Resource"})
      {:ok, %{"id" => "124", "name" => "New Resource"}}

  """
  def post_resource(resource_params) do
    url = "#{@api_base_url}/resources"
    headers = [{"Content-Type", "application/json"}]
    body = Jason.encode!(resource_params)

    case post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code}} when status_code in 400..499 ->
        {:error, "Client error: #{status_code}"}

      {:ok, %HTTPoison.Response{status_code: status_code}} when status_code in 500..599 ->
        {:error, "Server error: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
