defmodule Imageserver.Validation do  
  @moduledoc """
    Handles verification of the authentication token. The
    actual verification of the token is actually performed
    in the User model object. This module simply acts as
    a proxy for the Mellon authentication helpers used in
    the router.
  """
  import Joken
  alias Imageserver.User

  @spec validate({Plug.Conn.t, String.t}) :: {:ok, User.t, Plug.Conn.t} | {:error, [], Plug.Conn.t}
  def validate({conn, token}) do
    User.verify_token(token)
    |> handle(conn)
  end

  defp handle(%User{} = user, conn) do
    {:ok, user, conn}
  end
  defp handle(%{error: _error}, conn) do
    {:error, [], conn}
  end
end