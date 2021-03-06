defmodule Imageserver.UserView do
  use Imageserver.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, Imageserver.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, Imageserver.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email,
      password_hash: user.password_hash}
  end
end
