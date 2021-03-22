defmodule HnAggregatorWeb.ItemController do
  @moduledoc """
    The item or story controller that handles http requests.
  """

  use HnAggregatorWeb, :controller
  action_fallback HnAggregator.FallbackController

  @server Application.get_env(:hn_aggregator, :aggregation_server)

  def show(conn, %{"id" => id}) do
    with {:ok, id} <- parse_int(id),
         {:ok, item} <- @server.get(id) do
      render(conn, :show, item: item)
    end
  end

  def index(conn, %{"page" => page}) do
    with {:ok, page} <- parse_int(page),
         {:ok, page_items} <- @server.page(page) do
      render(conn, :index, items: page_items)
    end
  end

  def index(conn, _params) do
    with {:ok, items} = @server.all() do
      render(conn, :index, items: items)
    end
  end

  defp parse_int(num) do
    case Integer.parse(num) do
      {int, ""} -> {:ok, int}
      _ -> {:error, :wrong_param}
    end
  end
end
