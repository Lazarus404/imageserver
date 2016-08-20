defmodule Imageserver.FileController do
  @moduledoc """
  Provides file storage and retrieval endpoints. Files are
  proxied to AWS S3 via the Arc library.
  """
  use Imageserver.Web, :controller

  import Imageserver.Helpers.ErrorRender
  alias Imageserver.{User, Image, SiteAssets}

  @doc """
  Updates signature of all endpoints in this module to provide an additional
  User object parameter representing the currently logged in user.
  """
  def action(conn, _params) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns[:credentials]])
  end

  @doc """
  Simple GET retrieval endpoint for returning all images for the currently 
  logged in user.
  """
  def index(conn, _params, current_user = %User{}) do
    images = User.get_images(current_user.id)
    
    conn
    |> put_status(200)
    |> render("images.json", images: images)
  end

  @doc """
  Complex GET request using two parameters.

  page: Represents the current page for pagination. Starts from 0 (zero).
  per_page: Number of items to retrieve per page. Acts as an offset ((page+1) * per_page)
  """
  def paginate(conn, %{"page" => page, "per_page" => per_page}, current_user = %User{}) do
    {page, _} = Integer.parse(page)
    {per_page, _} = Integer.parse(per_page)
    images = User.get_images_paginated(current_user.id, page, per_page)

    conn
    |> put_status(200)
    |> render("images_paginated.json", images: images)
  end

  @doc """
  Handles incorrectly formatted paginate parameters, returning a decently
  formatted response.
  """
  def paginate(conn, _params, _current_user) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{status: "error", data: "Required parameters not sent"})
  end

  @doc """
  Upload POST endpoint for receiving image uploads with associated Trello card information.
  The Trello card is dispatched asynchronously, so as to reduce the time to completion.
  """
  def file_upload(conn, %{"upload" => upload, "image" => %{"name" => name, "description" => desc}}, current_user = %User{}) do
    scope = %{filename: get_filename(upload.filename)}
    {:ok, file} = SiteAssets.store({upload, scope})

    changeset = Image.changeset(%Image{}, %{name: name, description: desc, filename: scope.filename, user_id: current_user.id})
    case Repo.insert(changeset) do
      {:ok, _image} ->
        spawn __MODULE__, :trello_submit, [name, desc, SiteAssets.url(scope.filename)]
        conn
        |> put_status(:created)
        |> json(%{data: %{original: file, filename: scope.filename}})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", data: changeset_error(changeset)})
    end
  end

  @doc """
  Handles incorrectly formatted upload parameters, returning a decently
  formatted response.
  """
  def file_upload(conn, _params, _current_user) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{status: "error", data: "Required parameters not sent"})
  end

  @doc """
  Helper function to dispatch Trello card creation.
  """
  @spec trello_submit(String.t, String.t, String.t) :: String.t
  def trello_submit(name, desc, filename) do
    Imageserver.TrelloAdmin.add_card(Application.get_env(:imageserver, :trello_board, "Imageserver"), Application.get_env(:imageserver, :trello_card, "Tasks"), name, desc, filename)
  end

  @doc """
  Replace the root part of a filename with a UUID, preserving
  its extension
  """
  @spec get_filename(String.t) :: String.t
  defp get_filename(filename) do
    UUID.uuid4() <> Path.extname(filename)
  end
end