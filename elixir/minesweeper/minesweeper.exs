defmodule Minesweeper do
  @doc """
  Annotate empty spots next to mines with the number of mines next to them.
  """
  @spec annotate([String.t()]) :: [String.t()]

  def annotate(board) do
    board
    |> list_to_matrix()
    |> fill()
  end

  # Fill in blanks with number of adjacent mines, also converts back to
  # a list of strings
  def fill(matrix) do
    for y <- Map.keys(matrix) do
      for x <- Map.keys(matrix[0]), into: "" do
        # Only count mines on blank spaces
        case matrix[y][x] do
          42 -> "*"
          32 -> count_mines(matrix, x, y)
        end
      end
    end
  end

  # Count mines in adjacent spaces to x, y and return the value to fill
  # Returns: an Integer string of adjacent mines, or space if there are 0 mines
  def count_mines(matrix, x, y) do
    count = 0
    |> check_space(matrix, x-1, y-1) # up left
    |> check_space(matrix, x,   y-1)   # up
    |> check_space(matrix, x+1, y-1) # up right
    |> check_space(matrix, x+1, y)   # right
    |> check_space(matrix, x+1, y+1) # down right
    |> check_space(matrix, x,   y+1)   # down
    |> check_space(matrix, x-1, y+1) # down left
    |> check_space(matrix, x-1, y)   # left

    # Convert to string
    case count do
      0 -> " "
      _ -> Integer.to_string(count)
    end
  end

  # Check what is in a space, if its a bomb, increment count.
  def check_space(count, matrix, x, y) do
    case matrix[y][x] do
      42  -> count + 1 # Found a mine!
      nil -> count     # Off the board
      32  -> count     # Found a space
      _   -> count
    end
  end

  # Convert a list of strings into a matrix:
  # %{
  #   0 => %{0 => 32, 1 => 42, ...}
  #   1 => %{0 => 42, 1 => 31, ...}
  #   ...
  # }
  def list_to_matrix(ll) when is_list(ll) do
    list_to_matrix(ll, %{}, 0)
  end

  # Make a map for each string in the list
  defp list_to_matrix([h | t], map, index) when is_binary(h) do
    map = Map.put(map, index, list_to_matrix(String.to_charlist(h), %{}, 0))
    list_to_matrix(t, map, index + 1)
  end

  # Make a map for each char in the charlist
  defp list_to_matrix([h | t], map, index) do
    map = Map.put(map, index, h)
    list_to_matrix(t, map, index + 1)
  end

  defp list_to_matrix([], map, _index), do: map
  
end
