defmodule HnAggregator.StoriesFetcherTask do
  @moduledoc """
    A task that fetches new stories at a time interval and updates the aggregation server.
  """

  use Task
  alias HnAggregator.HackerNewsBeh

  @client Application.get_env(:hn_aggregator, :hn_api)
  @ops Application.get_env(:hn_aggregator, :fetcher, [])

  @spec start_link(%{:pid => pid, optional(:interval) => integer}) :: {:ok, pid}
  def start_link(%{pid: pid} = args) do
    interval = Map.get(args, :interval, Keyword.get(@ops, :refresh_interval, 30_000))
    Task.start_link(__MODULE__, :loop, [pid, interval])
  end

  @spec loop(atom | pid, integer, (() -> [HackerNewsBeh.response(any)])) :: any
  def loop(pid, interval, fetcher_fn \\ &@client.new_stories/0) do
    with {:ok, stories} <- fetcher_fn.() do
      send(pid, {:update, stories})
    end

    receive do
      {:stop, pid} -> send(pid, :ok)
    after
      interval -> loop(pid, interval, fetcher_fn)
    end
  end
end
