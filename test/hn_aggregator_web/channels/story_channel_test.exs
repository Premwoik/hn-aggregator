defmodule HnAggregatorWeb.StoryChannelTest do
  use HnAggregatorWeb.ChannelCase

  alias HnAggregatorWeb.{UserSocket, StoryChannel}
  alias HnAggregator.{Item, ItemExample}

  setup do
    {:ok, _, socket} =
      UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(StoryChannel, "stories:lobby")

    %{socket: socket}
  end

  test "join response", %{} do
    {:ok, resp, _socket} =
      UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(StoryChannel, "stories:lobby")

    assert ^resp = ItemExample.stories_view()
  end

  test "broadcast new stories", %{socket: _socket} do
    {stories, expected} = gen_random_stories(15)
    StoryChannel.broadcast_update(stories)
    assert_broadcast "update", ^expected
  end

  test "broadcast new stories by isolated server", %{socket: _socket} do
    {:ok, pid} =
      start_supervised(%{
        id: :test_server2,
        start: {HnAggregator.AggregationServer, :start_link, [nil, :test_server2]}
      })

    {stories1, expected1} = gen_random_stories(15)
    {stories2, expected2} = gen_random_stories(5)

    send(pid, {:update, stories1})
    send(pid, {:update, stories2})

    assert_broadcast "update", ^expected1
    assert_broadcast "update", ^expected2
    stop_supervised(:test_server2)
  end

  defp gen_random_stories(max) do
    n = Enum.random(1..max)

    Enum.map(
      1..n,
      fn _ ->
        id = Enum.random(1..15_000)
        {%Item{id: id, type: "story"}, %{id: id, type: "story"}}
      end
    )
    |> Enum.unzip()
  end
end
