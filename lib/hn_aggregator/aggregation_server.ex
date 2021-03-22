defmodule HnAggregator.AggregationServer do
  @moduledoc """
    The aggregation server that stores the new data fetched from HN servers and allows to read it.
  """
  use GenServer
  require Logger
  alias HnAggregator.Item

  @broadcast_handler Application.get_env(:hn_aggregator, :broadcast_handler)

  defmodule BroadcastBeh do
    @callback broadcast_update([%Item{}]) :: any
  end

  @spec all() :: {:ok, [%Item{}]}
  def all() do
    {:ok, GenServer.call(__MODULE__, :get_all)}
  end

  @spec page(pos_integer, pos_integer) :: {:ok, [%Item{}]} | {:error, atom}
  def page(num, per_page \\ 10)

  def page(num, per_page) when per_page > 0 and num > 0 do
    case GenServer.call(__MODULE__, {:get_paginated, num, per_page}) do
      [] -> {:error, :not_found}
      res -> {:ok, res}
    end
  end

  def page(_, _), do: {:error, :wrong_param}

  @spec get(integer) :: {:ok, %Item{}} | {:error, atom}
  def get(id) do
    case GenServer.call(__MODULE__, {:get, id}) do
      nil -> {:error, :not_found}
      res -> {:ok, res}
    end
  end

  # Callbacks
  def start_link(state, name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, state, name: name)
  end

  @impl true
  def init(_opts) do
    Logger.debug("Initializing AggregationServer!")
    {:ok, %{stories: []}}
  end

  @impl true
  def handle_call({:get, id}, _from, %{stories: stories} = state) do
    res = Enum.find(stories, fn s -> s.id == id end)
    {:reply, res, state}
  end

  @impl true
  def handle_call({:get_paginated, num, per_page}, _from, %{stories: stories} = state) do
    num = num - 1
    from = num * per_page
    to = from + per_page - 1
    res = Enum.slice(stories, from..to)
    {:reply, res, state}
  end

  @impl true
  def handle_call(:get_all, _from, %{stories: stories} = state) do
    {:reply, stories, state}
  end

  @impl true
  def handle_info({:update, stories}, state) do
    Logger.debug("Stories have been reloaded!")
    @broadcast_handler.broadcast_update(stories)
    state = Map.put(state, :stories, stories)
    {:noreply, state}
  end
end
