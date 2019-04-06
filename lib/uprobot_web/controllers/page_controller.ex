defmodule UprobotWeb.PageController do
  use UprobotWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
