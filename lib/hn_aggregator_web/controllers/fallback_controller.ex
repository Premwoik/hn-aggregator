defmodule HnAggregator.FallbackController do
  @moduledoc false
  use HnAggregatorWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(HnAggregatorWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :wrong_param}) do
    conn
    |> put_status(:not_acceptable)
    |> put_view(HnAggregatorWeb.ErrorView)
    |> render(:"406")
  end

  def call(conn, unexpected_error) do
    send_resp(conn, 500, "Not handled error: #{inspect(unexpected_error)}")
  end
end
