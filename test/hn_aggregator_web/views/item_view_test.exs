defmodule HnAggregatorWeb.ItemViewTest do
  @moduledoc false

  use HnAggregatorWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View
  alias HnAggregator.Item

  test "render story" do
    item = %Item{id: 12, type: "story", title: "Test story", by: "test_user"}

    expected = %{id: 12, type: "story", title: "Test story", by: "test_user"}
    assert expected == render(HnAggregatorWeb.ItemView, "show.json", item: item)
  end
end
