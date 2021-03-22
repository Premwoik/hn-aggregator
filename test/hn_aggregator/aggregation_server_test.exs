defmodule HnAggregator.AggregationServerTest do
  use ExUnit.Case
  doctest HnAggregator.AggregationServer

  alias HnAggregator.ItemExample

  test "is server alive?" do
    status =
      Process.whereis(HnAggregator.AggregationServer)
      |> Process.alive?()

    assert status
  end

  test "update server stories" do
    {:ok, pid} =
      start_supervised(%{
        id: :test_server,
        start: {HnAggregator.AggregationServer, :start_link, [nil, :test_server]}
      })

    init_state = GenServer.call(:test_server, :get_all)
    new_state = ItemExample.stories(1, 10)
    #    update server state
    send(pid, {:update, new_state})

    updated_state = GenServer.call(:test_server, :get_all)
    stop_supervised(:test_server)

    assert init_state == []
    assert updated_state == new_state
  end

  test "get all" do
    all = HnAggregator.AggregationServer.all()
    assert all == {:ok, ItemExample.stories()}
  end

  test "get page" do
    page1 = HnAggregator.AggregationServer.page(2)
    assert page1 == {:ok, ItemExample.stories(11, 10)}
  end

  test "get missing page" do
    page = HnAggregator.AggregationServer.page(10)
    assert page == {:error, :not_found}
  end

  test "get page with wrong params" do
    page_neg1 = HnAggregator.AggregationServer.page(-1)
    page0 = HnAggregator.AggregationServer.page(0)
    page1 = HnAggregator.AggregationServer.page(1, 0)
    page2 = HnAggregator.AggregationServer.page(2, -1)

    assert page_neg1 == {:error, :wrong_param}
    assert page0 == {:error, :wrong_param}
    assert page1 == {:error, :wrong_param}
    assert page2 == {:error, :wrong_param}
  end

  test "get item" do
    id = 1
    story = HnAggregator.AggregationServer.get(id)
    assert story == {:ok, ItemExample.story(id)}
  end

  test "get not existing item" do
    story = HnAggregator.AggregationServer.get(999)
    assert story == {:error, :not_found}
  end
end
