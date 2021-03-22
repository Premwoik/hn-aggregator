defmodule HnAggregator.ItemExample do
  @moduledoc """
      A helper module used in tests.
  """

  alias HnAggregator.Item

  def stories(from \\ 1, limit \\ 50) do
    to = from + limit - 1
    Enum.map(from..to, fn id -> %Item{id: id, type: "story"} end)
  end

  def stories_view(from \\ 1, limit \\ 50) do
    to = from + limit - 1
    Enum.map(from..to, fn id -> %{id: id, type: "story"} end)
  end

  def story(id) do
    stories()
    |> Enum.find(fn %{id: id2} -> id == id2 end)
  end
end
