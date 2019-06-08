defmodule UprobotWeb.PageController do
  use UprobotWeb, :controller

  def index(conn, _params) do
    conn
    |> redirect(to: Routes.site_path(conn, :index))
  end
end
