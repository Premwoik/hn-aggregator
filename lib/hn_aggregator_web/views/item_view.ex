defmodule HnAggregatorWeb.ItemView do
  @moduledoc false
  use HnAggregatorWeb, :view

  def render("index.json", %{items: items}) do
    render_many(items, HnAggregatorWeb.ItemView, "item.json")
  end

  def render("show.json", %{item: item}) do
    render_one(item, HnAggregatorWeb.ItemView, "item.json")
  end

  def render("item.json", %{item: item}) do
    item
    |> Map.from_struct()
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Map.new()
  end
end
