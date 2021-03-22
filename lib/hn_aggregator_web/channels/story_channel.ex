defmodule HnAggregatorWeb.StoryChannel do
  @moduledoc """
   A channel used to broadcast to all subscribers the new stories when the aggregation server refreshed.
  """

  use Phoenix.Channel
  alias HnAggregatorWeb.{ItemView, Endpoint}

  @behaviour HnAggregator.AggregationServer.BroadcastBeh
  @server Application.get_env(:hn_aggregator, :aggregation_server)

  # handles the special `"lobby"` subtopic
  def join("stories:lobby", _payload, socket) do
    {:ok, items} = @server.all()
    stories = ItemView.render("index.json", %{items: items})

    {:ok, stories, socket}
  end

  def broadcast_update(items) do
    rendered = ItemView.render("index.json", %{items: items})
    Endpoint.broadcast("stories:lobby", "update", rendered)
  end
end
