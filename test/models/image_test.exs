defmodule Imageserver.ImageTest do
  use Imageserver.ModelCase

  alias Imageserver.Image

  @valid_attrs %{description: "some content", filename: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Image.changeset(%Image{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Image.changeset(%Image{}, @invalid_attrs)
    refute changeset.valid?
  end
end
