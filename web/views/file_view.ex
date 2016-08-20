defmodule Imageserver.FileView do
  use Imageserver.Web, :view

  alias Imageserver.SiteAssets

  def render("images_paginated.json", %{images: %{has_next: has_next, has_prev: has_prev, list: list}}) do
    %{
      has_next: has_next,
      has_prev: has_prev,
      list: render_many(list, Imageserver.FileView, "image.json")
    }
  end

  def render("images.json", %{images: images}) do
    %{data: render_many(images, Imageserver.FileView, "image.json")}
  end

  def render("image.json", %{file: image}) do
    %{
      filename: SiteAssets.url(image.filename),
      thumbnail: SiteAssets.url(get_thumbnail_path(image.filename)),
      name: image.name,
      description: image.description
    }
  end

  defp get_thumbnail_path(filename) do
    Path.rootname(filename) <> "__thumbnail" <> Path.extname(filename)
  end
end
