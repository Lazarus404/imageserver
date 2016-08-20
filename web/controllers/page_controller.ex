defmodule Imageserver.PageController do
  use Imageserver.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
