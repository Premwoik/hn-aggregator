defmodule HnAggregator.HackerNewsTestClient do
  @moduledoc """
    A client for testing.
  """

  @behaviour HnAggregator.HackerNewsBeh

  alias HnAggregator.{ItemExample}

  def get_story(id) do
    story = ItemExample.story(id)
    {:ok, story}
  end

  def new_stories() do
    stories = ItemExample.stories()
    {:ok, stories}
  end
end
