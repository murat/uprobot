defmodule UprobotWeb.SessionController do
  @moduledoc false

  use UprobotWeb, :controller

  alias Uprobot.Accounts
  alias Uprobot.Accounts.User

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset, error: nil)
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Accounts.get_user_by!(email: email) do
      user ->
        case Bcrypt.check_pass(user, password, hash_key: :password_digest) do
          {:ok, user} ->
            conn
            |> put_session(:current_user_id, user.id)
            |> put_flash(:info, "User signed successfully.")
            |> redirect(to: Routes.page_path(conn, :index))

          {:error, reason} ->
            render(conn, "new.html", changeset: Accounts.change_user(%User{}), error: reason)
        end

      nil ->
        render(conn, "new.html",
          changeset: Accounts.change_user(%User{}),
          error: "User not found!"
        )
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
