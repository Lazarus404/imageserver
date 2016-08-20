defmodule Imageserver.RegistrationController do
  @moduledoc """
  Purely handles registration POST requests, creating a User
  object from the passed 'email' and 'password' parameters.
  All users are excepted.
  """ 
  use Imageserver.Web, :controller

  alias Imageserver.User

  plug :scrub_params, "user" when action in [:create]

  @doc """
  Create a new User object in the local database using
  the passed 'email' and 'password' parameters.
  """
  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render(Imageserver.UserView, "show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Imageserver.ChangesetView, "error.json", changeset: changeset)
    end
  end
end