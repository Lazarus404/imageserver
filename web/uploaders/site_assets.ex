defmodule Imageserver.SiteAssets do
  @moduledoc """
  Handles all image uploads and conversions to S3. This
  module uses ImageMagick for thumbnail generation.
  """
  use Arc.Definition

  @versions [:original, :thumb]
  @acl :public_read

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(file.file_name |> String.downcase |> Path.extname)
  end

  def __storage, do: Arc.Storage.S3

  def filename(:original, {file, scope}) do
    if scope do
      Path.rootname(scope.filename)
    else
      Path.rootname(file.file_name)
    end
  end

  def filename(:thumb, {file, scope}) do
    filename = if scope do
      scope.filename
    else
      file.file_name
    end
    Path.rootname(filename) <> "__thumbnail"
  end

  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 200x200\>"}
  end

  def s3_object_headers(_, {file, scope}) do
    [content_type: Plug.MIME.path(file.file_name)]
  end
end
