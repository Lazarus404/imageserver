defmodule Imageserver.UserTest do
  use Imageserver.ModelCase

  alias Imageserver.User

  @valid_attrs %{email: "test.user@some-domain.com", password: "validPass"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    cs = User.changeset(%User{}, @valid_attrs)
    assert cs.valid?
  end

  test "changeset with invalid attributes" do
    cs = User.changeset(%User{}, @invalid_attrs)
    refute cs.valid?
  end

  test "password_hash field receives a hash" do  
    cs = User.changeset(%User{}, @valid_attrs)
    assert Comeonin.Bcrypt.checkpw(@valid_attrs.password, Ecto.Changeset.get_change(cs, :password_hash))
  end
end
