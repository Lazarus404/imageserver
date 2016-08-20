defmodule Imageserver.Router do
  use Imageserver.Web, :router

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

  pipeline :authenticated do  
    plug Mellon, validator: {Imageserver.Validation, :validate, []}, header: "authorization"
  end

  scope "/", Imageserver do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api/", Imageserver do  
    pipe_through :api
    
    # resources "/users", UserController

    post "/auth/register", RegistrationController, :create
    post "/auth/login", SessionController, :login
  end

  scope "/api/", Imageserver do  
    pipe_through :api
    pipe_through :authenticated

    get "/auth/validate", SessionController, :validate

    post "/image", FileController, :file_upload
    get "/image", FileController, :index
    get "/image/:page/:per_page", FileController, :paginate
  end
end
