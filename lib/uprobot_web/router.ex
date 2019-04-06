defmodule UprobotWeb.Router do
  use UprobotWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UprobotWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "sites", SiteController
  end

  # Other scopes may use custom stacks.
  # scope "/api", UprobotWeb do
  #   pipe_through :api
  # end
end
