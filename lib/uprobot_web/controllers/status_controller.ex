defmodule UprobotWeb.StatusController do
  @moduledoc false
  use UprobotWeb, :controller

  alias Uprobot.Monit

  def delete(conn, %{"site_id" => site_id, "id" => id}) do
    site = Monit.get_site!(site_id)
    status = Monit.get_status!(id)
    {:ok, _status} = Monit.delete_status(status)

    conn
    |> put_flash(:info, "Status deleted successfully.")
    |> redirect(to: Routes.site_path(conn, :show, site))
  end
end
