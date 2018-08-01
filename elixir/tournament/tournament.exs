defmodule Tournament do

  @inital_win  %{played: 1, win: 1, loss: 0, draw: 0, points: 3}
  @inital_loss %{played: 1, win: 0, loss: 1, draw: 0, points: 0}
  @inital_draw %{played: 1, win: 0, loss: 0, draw: 1, points: 1}
  @delimiter " | "
  @header "Team                           | MP |  W |  D |  L |  P"

  @doc """
  Given `input` lines representing two teams and whether the first of them won,
  lost, or reached a draw, separated by semicolons, calculate the statistics
  for each team's number of games played, won, drawn, lost, and total points
  for the season, and return a nicely-formatted string table.

  A win earns a team 3 points, a draw earns 1 point, and a loss earns nothing.

  Order the outcome by most total points for the season, and settle ties by
  listing the teams in alphabetical order.
  """
  @spec tally(input :: list(String.t())) :: String.t()
  def tally(input) do
    input
    |> Enum.reduce(%{}, &tally_game(&1, &2))
    |> sort()
    |> format()
  end

  ### Formatting logic ###

  # Format into a pretty table from our sorted record structure:
  # [ {team1, %{data}}, {team2, %{data}}, ...]
  defp format(record) do
    Enum.reduce(record, @header, &format_line(&1, &2))
  end

  #Take a team record and format a line
  def format_line({team, data}, acc) do
    #convert all of our ints to strings
    data = for {key, val} <- data, into: %{}, do: {key, Integer.to_string(val)}

    #layout the row
    acc <> "\n" <>
    String.pad_trailing(team, 30, " ")      <> @delimiter <>
    String.pad_leading(data.played, 2, " ") <> @delimiter <>
    String.pad_leading(data.win,    2, " ") <> @delimiter <>
    String.pad_leading(data.draw,   2, " ") <> @delimiter <>
    String.pad_leading(data.loss,   2, " ") <> @delimiter <>
    String.pad_leading(data.points, 2, " ")
  end

  ### Sorting Logic ###

  # Take our record structure below and turn it into a sorted list
  # Sorted by: points, then by alphabetical team name
  defp sort(record) do
    record
    |> Map.to_list
    |> Enum.sort(&record_sorter(&1, &2))
  end

  # Helper function to compare two records for sorting,
  # returns true if team_a should proceed team_b
  defp record_sorter({_team_a, %{points: a_points}}, {_team_b, %{points: b_points}})
  when a_points != b_points do
    cond do
      a_points > b_points -> true
      a_points < b_points -> false
    end
  end

  # Case for points being equal, sort alphabetically
  defp record_sorter({team_a, _}, {team_b, _}) do
    String.downcase(team_a) <= String.downcase(team_b)
  end

  ### Tally and Record logic ###

  #Record structure:
  # %{
  #   "Badgers" => %{played: 0, win: 0, loss: 0, draw: 0, points: 0}
  #   "Kittens" => %{played: 0, win: 0, loss: 0, draw: 0, points: 0}
  #   ...
  # }

  # Update the tally for one game
  defp tally_game(data, record) do
    case String.split(data, ";") do
      [team_a, team_b, "win"]  ->  update_record(record, :win,  team_a, team_b)
      [team_a, team_b, "loss"] ->  update_record(record, :loss, team_a, team_b)
      [team_a, team_b, "draw"] ->  update_record(record, :draw, team_a, team_b)
      _ -> record #invalid line just skip it.
    end
  end

  # Update the record for one Game (ie two teams)
  # Team A beat Team B
  defp update_record(record, :win, team_a, team_b) do
    record
    |> Map.update(team_a, @inital_win,  &update_win(&1))
    |> Map.update(team_b, @inital_loss, &update_loss(&1))
  end

  # Team A lost to Team B
  defp update_record(record, :loss, team_a, team_b) do
    record
    |> Map.update(team_b, @inital_win,  &update_win(&1))
    |> Map.update(team_a, @inital_loss, &update_loss(&1))
  end

  #Team A drew with Team B
  defp update_record(record, :draw, team_a, team_b) do
    record
    |> Map.update(team_a, @inital_draw, &update_draw(&1))
    |> Map.update(team_b, @inital_draw, &update_draw(&1))
  end

  # Update the record for a single team's win/loss/draw
  defp update_win(record) do
    record
    |> Map.update!(:played, &(&1 + 1))
    |> Map.update!(:win,    &(&1 + 1))
    |> Map.update!(:points, &(&1 + 3))
  end

  defp update_loss(record) do
    record
    |> Map.update!(:played, &(&1 + 1))
    |> Map.update!(:loss,   &(&1 + 1))
  end

  defp update_draw(record) do
    record
    |> Map.update!(:played, &(&1 + 1))
    |> Map.update!(:draw,   &(&1 + 1))
    |> Map.update!(:points, &(&1 + 1))
  end
end
