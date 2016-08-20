defmodule Imageserver.Helpers.ErrorRender do
  @moduledoc """
  Helper function for rendering ChangeSet error
  """

  @doc """
  Converts a ChangeSet with errors to a legible error
  list tree.
  """
  def changeset_error(changeset) do
    Enum.map(changeset.errors, fn {field, detail} ->
      %{
        source: %{ pointer: "/data/attributes/#{field}" },
        title: "Invalid Attribute",
        detail: render_detail(detail)
      }
    end)
  end

  defp render_detail({message, values}) do
    Enum.reduce values, message, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end
  end

  defp render_detail(message) do
    message
  end
end