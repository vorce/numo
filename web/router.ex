defmodule Numo.Router do
  use Numo.Web, :router

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

  scope "/", Numo do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/messages", MessageController
    get "/queue/:name", MessageController, :queue
    get "/_status", StatusController, :status
  end

  forward "/metrics", Beaker.Web
end
