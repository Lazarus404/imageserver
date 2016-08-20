defmodule Imageserver.Image do
  @moduledoc """
  Represents an image uploaded to S3. Associated
  thumbnail URL's are generated from the filename
  attribute
  """
  use Imageserver.Web, :model

  schema "images" do
    field :name, :string
    field :description, :string
    field :filename, :string
    belongs_to :user, Imageserver.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :filename, :user_id])
    |> validate_required([:name, :description, :filename])
  end
end
