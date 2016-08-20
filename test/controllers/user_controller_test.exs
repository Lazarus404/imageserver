defmodule Imageserver.UserControllerTest do  
  use Imageserver.ConnCase

  alias Imageserver.User

  @valid_attrs %{email: "test.user@some-domain.com", password: "validPass"}
  @invalid_attrs %{}

  # allow for json headers
  setup do
    {:ok, conn: build_conn() |> put_req_header("accept", "application/json")}
  end

  test "creates user with valid data", %{conn: conn} do
    conn = post conn, registration_path(conn, :create), user: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(User, email: @valid_attrs.email)
  end

  test "fails to create user when data is not valid", %{conn: conn} do
    conn = post conn, registration_path(conn, :create), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "emails should be unique", %{conn: conn} do
    post conn, registration_path(conn, :create), user: @valid_attrs
    conn = post conn, registration_path(conn, :create), user: @valid_attrs
    errors = json_response(conn, 422)["errors"]
    assert errors != %{}
    assert Map.has_key?(errors, "email")
    assert Map.get(errors, "email") == ["has already been taken"]
  end
end