defmodule Imageserver.TrelloAdmin do
  @moduledoc """
  Trello functions module. The primary function here is
  the add_card/5 function, which waterfalls through each
  other function in order to implement a new card. The
  board and list should already exist and should be
  specified in the config/config.exs file.
  """
  import ExTrello.API.Base
  alias ExTrello.Parser
  

  @doc """
  Retrieves a Trello board string id from its name
  """
  @spec get_board_id(String.t) :: {:ok, String.t} | :error
  def get_board_id(name) do
    boards = ExTrello.boards([fields: "name"])
    case Enum.find(boards, fn(b) -> b.name == name end) do
      nil -> :error
      board -> {:ok, board.id}
    end
  end

  @doc """
  Retrieves a Trello board object from its name
  """
  @spec get_board(String.t) :: {:ok, ExTrello.Model.Board.t} | :error
  def get_board(name) do
    case get_board_id(name) do
      :error -> :error
      {:ok, id} -> {:ok, ExTrello.board(id, lists: "all")}
    end
  end

  @doc """
  Retrieves a list from a Trello board from its name
  """
  @spec get_list(ExTrello.Model.Board.t, String.t) :: {:ok, ExTrello.Model.List.t} | :error
  def get_list(board = %ExTrello.Model.Board{}, name) do
    case Enum.find(board.lists, fn(l) -> l.name == name end) do
      nil -> :error
      list -> {:ok, list}
    end
  end

  @doc """
  Retrieves a Trello list object from its name and its boards name
  """
  @spec get_list(String.t, String.t) :: {:ok, ExTrello.Model.List.t} | :error
  def get_list(board_name, name) do
    with {:ok, board} <- get_board(board_name),
         {:ok, list} <- get_list(board, name),
         do: {:ok, list}
  end

  @doc """
  Adds a card to Trello for the given board object
  """
  @spec create_card(ExTrello.Model.List.t, String.t, String.t, String.t) :: {:ok, String.t} | {:error, String.t}
  def create_card(list, card_name, card_desc, image_url) do
    card = ExTrello.create_card(list, card_name)
    |> ExTrello.edit_card(desc: card_desc)
    request(:post, "cards/#{card.id}/attachments", [url: image_url])
    |> Parser.parse_action
  end

  @doc """
  Adds a card to Trello via passed board and list names. The card must present a name,
  description and image URL values.
  """
  @spec add_card(String.t, String.t, String.t, String.t, String.t) :: String.t | :error
  def add_card(board_name, list_name, card_name, card_desc, image_url) do
    with {:ok, list} <- get_list(board_name, list_name),
         {:ok, card_id} <- create_card(list, card_name, card_desc, image_url),
         do: card_id
  end
end