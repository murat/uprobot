defmodule UprobotWeb.DashboardController do
  @moduledoc false
  use UprobotWeb, :controller

  alias Uprobot.Monit

  def index(conn, _params) do
    sites = Monit.list_sites()
    render(conn, "index.html", sites: sites)
  end

  def show(conn, %{"id" => id}) do
    {site, stats} = Monit.get_site_with_statuses!(id)
    # raise stats
    render(conn, "show.html", site: site, stats: stats)
  end
end
