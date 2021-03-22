defmodule HnAggregator.HackerNewsBeh do
  @moduledoc """
    A behaviour defining actions fetch stories from HN api.
  """

  @type response(data) :: {:ok, data} | {:error, any}

  @callback get_story(id :: integer | String.t()) :: response(%HnAggregator.Item{})
  @callback new_stories() :: response([%HnAggregator.Item{}])
end
