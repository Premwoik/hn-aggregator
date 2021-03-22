defmodule HnAggregator.HackerNewsClient do
  @moduledoc """


  """

  @behaviour HnAggregator.HackerNewsBeh
  @api_base_url Application.get_env(:hn_aggregator, :hn_api_url)

  def get_story(id) when is_integer(id) or is_binary(id) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get(@api_base_url <> "/item/" <> to_string(id) <> ".json"),
         {:ok, body} <- Jason.decode(body),
         {:ok, item} <- exists?(body) do
      item = Enum.map(item, fn {k, v} -> {String.to_atom(k), v} end)
      {:ok, struct(HnAggregator.Item, item)}
    else
      {:merror, e} -> {:error, e}
      _other -> {:error, :unable_to_load}
    end
  end

  def get_story(_), do: {:error, :wrong_param_type}

  def new_stories() do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get(@api_base_url <> "/newstories.json"),
         {:ok, ids} <- Jason.decode(body) do
      stories = Enum.take(ids, 50) |> Enum.map(fn id -> get_story(id) |> unwrap() end)
      {:ok, stories}
    else
      _ -> {:error, :unable_to_load}
    end
  end

  defp exists?(nil), do: {:merror, :not_found}
  defp exists?(x) when is_map(x), do: {:ok, x}
  defp exists?(_), do: {:merror, :wrong_format}

  defp unwrap({:ok, i}), do: i
  defp unwrap(_), do: nil
end
