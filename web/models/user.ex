defmodule Imageserver.User do
  @moduledoc """
  Represents an authenticated user. Each
  user can have many associated Image objects.
  """
  use Imageserver.Web, :model
  
  import Joken
  import Comeonin.Bcrypt

  alias Imageserver.Repo
  alias Imageserver.User
  alias Imageserver.Image

  schema "users" do  
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    has_many :images, Image, on_delete: :delete_all

    timestamps
  end

  @required_fields ~w(email password)
  @optional_fields ~w()
  @signer "secret"

  @doc """
  Creates a changeset based on the `model` and `params`.

  Simple password exchange from password to hashed password
  for security
  """
  def changeset(model, params \\ :empty) do  
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:email)
    |> validate_length(:password, min: 5)
    |> hash_password
  end

  @doc """
  Creates a valid JWT token from a User instance
  """
  @spec generate_token(User) :: String.t
  def generate_token(user) do
    %{user_id: user.id}
    |> token
    |> with_signer(hs256(@signer))
    |> sign
    |> get_compact
  end

  @doc """
  Deserialises and verifies a User object from
  a given JWT token string
  """
  @spec verify_token(String.t) :: User
  def verify_token(compact) do
    data = compact
    |> token
    |> with_signer(hs256(@signer))
    |> verify
    Repo.get(User, data.claims["user_id"])
  end

  @doc """
  Gets a list of images for a user via the users
  database id.
  """
  @spec get_images(Integer) :: list(Imageserver.Image.t)
  def get_images(user_id) do
    Repo.all from i in Imageserver.Image,
      join: u in assoc(i, :user),
      where: u.id == ^user_id
  end

  @doc """
  Returns a list of images with pagination, based on an offset of 
  'page' * 'per_page'. The page offset starts at 0 (zero).
  """
  @spec get_images_paginated(Integer, Integer, Integer) :: %{has_next: boolean(), has_prev: boolean(), list: list(Imageserver.Image.t)}
  def get_images_paginated(user_id, page, per_page) do
    count = per_page + 1
    result = Repo.all from i in Imageserver.Image,
      join: u in assoc(i, :user),
      where: u.id == ^user_id,
      limit: ^count,
      offset: ^(page * per_page)
    %{ has_next: (length(result) == count),
       has_prev: page > 0,
       list: Enum.slice(result, 0, count-1) }
  end

  @doc """
  Updates the changeset by converting the passed 'password'
  parameter to a salted 'password_hash' parameter, for storage
  in the local database.
  """
  @spec hash_password(Ecto.Changeset.t) :: Ecto.Changeset.t
  defp hash_password(changeset) do  
    if password = get_change(changeset, :password) do
      changeset
      |> put_change(:password_hash, hashpwsalt(password))
    else
      changeset
    end
  end
end