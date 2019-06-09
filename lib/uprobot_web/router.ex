defmodule UprobotWeb.Router do
  @moduledoc false

  use UprobotWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Uprobot.Plugs.CurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :ensure_auth do
    plug Uprobot.Plugs.EnsureAuth
  end

  scope "/", UprobotWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/sign_up", AuthController, :new
    post "/sign_up", AuthController, :create
    delete "/account/delete", AuthController, :delete

    get "/sign_in", SessionController, :new
    post "/sign_in", SessionController, :create

    resources "/sites", SiteController do
      resources "/statuses", StatusController, only: [:delete]
    end
  end

  scope "/", UprobotWeb do
    pipe_through [:browser, :ensure_auth]

    get "/account", AuthController, :edit
    post "/account", AuthController, :update
    delete "/account", AuthController, :delete
    delete "/sign_out", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", UprobotWeb do
  #   pipe_through :api
  # end
end
