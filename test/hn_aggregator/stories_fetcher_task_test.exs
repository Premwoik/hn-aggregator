defmodule HnAggregator.StoriesFetcherTaskTest do
  use ExUnit.Case
  doctest HnAggregator.StoriesFetcherTask

  alias HnAggregator.{ItemExample, StoriesFetcherTask}

  test "load stories and update server state" do
    {:ok, _pid} =
      start_supervised(%{
        id: :fetcher_process,
        start: {StoriesFetcherTask, :start_link, [%{pid: self(), interval: 50}]}
      })

    stories = ItemExample.stories()

    # first update
    assert_receive {:update, ^stories}, 100
    # second update after set interval
    assert_receive {:update, ^stories}, 100

    stop_supervised(:fetcher_process)
  end

  test "load stories error" do
    {:ok, pid} =
      Task.start_link(fn ->
        StoriesFetcherTask.loop(self(), 0, fn -> {:error, :unable_to_load} end)
      end)

    send(pid, {:stop, self()})
    assert_receive :ok, 100
    assert Process.alive?(pid) == false
  end
end
