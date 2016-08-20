defmodule Imageserver.SessionView do
  use Imageserver.Web, :view

  def render("session.json", %{token: token}) do
    %{data: %{token: token}}
  end

  def render("error.json", %{message: message}) do
    %{error: message}
  end
end
