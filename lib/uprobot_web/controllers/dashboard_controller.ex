defmodule UprobotWeb.DashboardController do
  @moduledoc false
  use UprobotWeb, :controller

  alias Uprobot.Monit

  def index(conn, _params) do
    sites = Monit.list_sites()
    render(conn, "index.html", sites: sites)
  end

  def show(conn, %{"id" => id}) do
    site = Monit.get_site!(id)
    render(conn, "show.html", site: site)
  end
end
