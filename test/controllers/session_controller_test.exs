defmodule Imageserver.SessionControllerTest do  
  use Imageserver.ConnCase

  alias Imageserver.User
  @valid_attrs %{email: "some content", password: "validPassword"}
  @invalid_attrs %{email: "non-existing-user@example.com", password: "no-password"}

  setup do
    cs = User.changeset(%User{}, @valid_attrs)
    {:ok, user} = Repo.insert cs
    token = User.generate_token(user)

    conn = build_conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn, user: user, token: token}
  end

  test "Cannot authenticate a non-existing user", %{conn: conn} do
    conn = get conn, session_path(conn, :login), user: @invalid_attrs
    assert json_response(conn, 422)
  end

  test "Authenticate a valid user", %{conn: conn} do
    conn = get conn, session_path(conn, :login), user: @valid_attrs
    assert json_response(conn, 200)["data"]["token"] != nil
  end

  test "validate token", %{conn: conn, token: token} do
    conn = put_req_header(conn, "authorization", "Token: " <> token)
    conn = get conn, session_path(conn, :validate)
    assert json_response(conn, 200)
  end

  test "validation fails if invalid token", %{conn: conn} do  
    conn = put_req_header(conn, "authorization", "Token: invalid-token")
    conn = get conn, session_path(conn, :validate)
    assert json_response(conn, 401)
  end
end