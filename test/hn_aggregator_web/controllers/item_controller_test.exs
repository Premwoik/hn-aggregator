defmodule HnAggregatorWeb.ItemControllerTest do
  use HnAggregatorWeb.ConnCase

  alias HnAggregatorWeb.ItemController

  @moduletag :capture_log

  doctest HnAggregatorWeb.ItemController

  test "module exists" do
    assert is_list(ItemController.module_info())
  end

  test "list all stories", %{conn: conn} do
    conn = get(conn, Routes.item_path(conn, :index))

    expected = Enum.map(1..50, &%{"id" => &1, "type" => "story"})
    assert expected == json_response(conn, 200)
  end

  test "get page", %{conn: conn} do
    params = [page: 4]
    conn = get(conn, Routes.item_path(conn, :index, params))

    expected = Enum.map(31..40, &%{"id" => &1, "type" => "story"})
    assert expected == json_response(conn, 200)
  end

  test "get page by wrong id", %{conn: conn} do
    params = [page: -1224]
    conn = get(conn, Routes.item_path(conn, :index, params))
    assert %{"errors" => %{"detail" => "Wrong Parameter"}} = json_response(conn, 406)
  end

  test "get page by not integer id", %{conn: conn} do
    params = [page: "2424sasd"]
    conn = get(conn, Routes.item_path(conn, :index, params))
    assert %{"errors" => %{"detail" => "Wrong Parameter"}} = json_response(conn, 406)
  end


  test "get story by id", %{conn: conn} do
    id = 12
    conn = get(conn, Routes.item_path(conn, :show, id))

    assert %{"id" => id, "type" => "story"} == json_response(conn, 200)
  end

  test "get story by wrong id", %{conn: conn} do
    id = -12
    conn = get(conn, Routes.item_path(conn, :show, id))
    assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
  end

  test "get story by not integer id", %{conn: conn} do
    id = "2424sasd"
    conn = get(conn, Routes.item_path(conn, :show, id))
    assert %{"errors" => %{"detail" => "Wrong Parameter"}} = json_response(conn, 406)
  end

end
