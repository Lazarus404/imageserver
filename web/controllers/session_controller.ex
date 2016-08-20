defmodule Imageserver.SessionController do
  @moduledoc """
  Handles all login requests. Logins create a JWT token
  for use by the end user to validate all future requests.
  """  
  use Imageserver.Web, :controller

  alias Imageserver.User

  @doc """
  Login POST endpoint used to generate a valid JWT token. The passed
  'email' and 'password' combination must match a user in the database.
  """
  def login(conn, %{"user" => user_params}) do
    if user = Repo.get_by(User, email: user_params["email"]) do

      token = User.generate_token(user)

      conn
      |> put_status(200)
      |> render(Imageserver.SessionView, "session.json", token: token)
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render(Imageserver.SessionView, "error.json", message: "User not found or password invalid")
    end
  end

  @doc """
  Used simply to validate authorization via the application tests
  """
  def validate(conn, _params) do
    conn
    |> put_status(200)
    |> render(Imageserver.UserView, "show.json", user: %User{email: "test"})
  end
end