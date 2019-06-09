defmodule Uprobot.Plugs.CurrentUser do
  import Plug.Conn

  alias Uprobot.Accounts

  def init(params), do: params

  def call(conn, _params) do
    case get_session(conn, :current_user_id) do
      nil ->
        conn
        |> assign(:current_user, nil)
        |> assign(:user_signed_in?, false)

      id ->
        user = Accounts.get_user!(id)

        conn
        |> assign(:current_user, user)
        |> assign(:user_signed_in?, true)
    end
  end
end
