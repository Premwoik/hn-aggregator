defmodule HnAggregator.HackerNewsClientTest do
  use ExUnit.Case

  alias HnAggregator.{Item, HackerNewsClient}

  setup do
    bypass = Bypass.open(port: 43443)
    {:ok, bypass: bypass}
  end

  test "request not existing story", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      assert "GET" == conn.method
      assert "/item/12.json" == conn.request_path
      Plug.Conn.resp(conn, 200, "null")
    end)

    assert {:error, :not_found} = HackerNewsClient.get_story(12)
  end

  test "request existing story", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      assert "GET" == conn.method
      assert "/item/8863.json" == conn.request_path

      response =
        "{\"by\":\"dhouston\",\"descendants\":71,\"id\":8863,\"kids\":[],\"score\":111,\"time\":1175714200,\"title\":\"My YC app: Dropbox - Throw away your USB drive\",\"type\":\"story\",\"url\":\"http:\/\/www.getdropbox.com\/u\/2\/screencast.html\"}"

      Plug.Conn.resp(conn, 200, response)
    end)

    expected =
      {:ok,
       %HnAggregator.Item{
         by: "dhouston",
         dead: nil,
         deleted: nil,
         descendants: 71,
         id: 8863,
         kids: [],
         parent: nil,
         parts: nil,
         poll: nil,
         score: 111,
         text: nil,
         time: 1_175_714_200,
         title: "My YC app: Dropbox - Throw away your USB drive",
         type: "story",
         url: "http://www.getdropbox.com/u/2/screencast.html"
       }}

    assert ^expected = HackerNewsClient.get_story(8863)
  end

  test "request story, but response is in wrong format", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      assert "GET" == conn.method
      assert "/item/12.json" == conn.request_path
      Plug.Conn.resp(conn, 200, "[]")
    end)

    assert {:error, :wrong_format} = HackerNewsClient.get_story(12)
  end

  test "request story, but 404", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      assert "GET" == conn.method
      assert "/item/12.json" == conn.request_path
      Plug.Conn.resp(conn, 404, "[]")
    end)

    assert {:error, :unable_to_load} = HackerNewsClient.get_story(12)
  end

  test "request story, but can't connect to server", %{bypass: bypass} do
    :ok = Bypass.down(bypass)
    assert {:error, :unable_to_load} = HackerNewsClient.get_story(12)
    :ok = Bypass.up(bypass)
  end

  test "request new stories - empty result 200", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      assert "GET" == conn.method
      assert "/newstories.json" == conn.request_path
      Plug.Conn.resp(conn, 200, "[]")
    end)

    assert {:ok, []} = HackerNewsClient.new_stories()
  end

  test "request new stories 200", %{bypass: bypass} do
    Bypass.expect(bypass, fn
      %Plug.Conn{request_path: "/newstories.json"} = conn ->
        assert "GET" == conn.method
        Plug.Conn.resp(conn, 200, "[1213, 42145]")

      %Plug.Conn{request_path: "/item/1213.json"} = conn ->
        assert "GET" == conn.method
        Plug.Conn.resp(conn, 200, "{\"id\": 1213, \"type\": \"story\"}")

      %Plug.Conn{request_path: "/item/42145.json"} = conn ->
        assert "GET" == conn.method
        Plug.Conn.resp(conn, 200, "nil")
    end)

    assert {:ok, [%Item{id: 1213}, nil]} = HackerNewsClient.new_stories()
  end
end
