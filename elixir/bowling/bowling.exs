defmodule Bowling do

  Code.load_file("frame.ex")
  alias Bowling.Frame
  @doc """
    Creates a new game of bowling that can be used to store the results of
    the game
  """
  @spec start() :: any
  def start do
    %{:current_frame => 1,  :total_score => 0, 1 => Frame.new()}
  end

  @doc """
    Records the number of pins knocked down on a single roll. Returns `any`
    unless there is something wrong with the given number of pins, in which
    case it returns a helpful message.
  """
  @spec roll(any, integer) :: any | String.t()
  def roll(%{current_frame: current_frame} = game, roll) when current_frame != :game_over do
    game = update_frame(game)
    roll(game, roll, game.current_frame)
  end

  def roll(%{current_frame: :game_over}, _roll) do
    {:error, "Cannot roll after game is over"}
  end

  # Ordinary Frame Roll
  def roll(game, roll, current_frame) when current_frame != 10 do
    frame = Map.get(game, current_frame)
    case Frame.roll(frame, roll) do
      {:ok, frame} -> Map.put(game, game.current_frame, frame)
      {:error, reason} -> {:error, reason}
    end
  end

  # 10th Frame Roll
  def roll(game, roll, 10) do
    frame = Map.get(game, 10)
    case Frame.roll_tenth(frame, roll) do
      #10th frame is done Game Over
      {:ok, %{state: :done} = frame} ->
        Map.put(game, game.current_frame, frame)
        |> Map.put(:current_frame, :game_over)
      {:ok, frame} -> Map.put(game, game.current_frame, frame)
      {:error, reason} -> {:error, reason}
    end
  end


    @doc """
      Returns the score of a given game of bowling if the game is complete.
      If the game isn't complete, it returns a helpful message.
    """
    @spec score(any) :: integer | String.t()
    def score(%{current_frame: :game_over} = game) do
      # Loop through each frame and set the score
      game = Enum.reduce(Enum.to_list(1..10), game, &Bowling.score_frame(&2, &1))
      game.total_score
    end

    def score(_game) do
      {:error, "Score cannot be taken until the end of the game"}
    end

  # Get the frame for the next roll, update the frame state if the old frame is done.
  def update_frame(game) do
    # Get our frame
    current_frame = Map.get(game, :current_frame)
    frame = Map.get(game, current_frame)

     cond do
       # Make a new frame and increment current frame
       frame.state == :done ->
         Map.put(game, current_frame + 1, Frame.new())
         |> Map.put(:current_frame, current_frame + 1)
       true -> game
    end
  end

  # Score frames 1 - 9
  def score_frame(game, frame_num) when frame_num != 10 do
    frame = Map.get(game, frame_num)
    score =
    case frame do
      %{mark: :strike} ->
        {first_roll, second_roll} = get_next_two_rolls(game, frame_num + 1)
        10 + first_roll + second_roll
      %{mark: :spare} ->
        10 + get_next_roll(game, frame_num + 1)
      _ ->
        frame.first_roll + frame.second_roll
    end

    Map.put(game, frame_num, Frame.set_score(frame, score))
    |> Map.update!(:total_score, &(&1 + score))
  end

  # Score the 10th frame
  def score_frame(game, 10) do
    tenth_frame = Map.get(game, 10)
    score =
      case tenth_frame.third_roll do
        nil -> tenth_frame.first_roll + tenth_frame.second_roll
        _   -> tenth_frame.first_roll + tenth_frame.second_roll + tenth_frame.third_roll
    end

    Map.put(game, 10, Frame.set_score(tenth_frame, score))
    |> Map.update!(:total_score, &(&1 + score))
  end

  def get_next_two_rolls(game, frame_num) do
    frame = Map.get(game, frame_num)
    case frame do
      %{mark: :strike} when frame_num != 10 -> {10, get_next_roll(game, frame_num + 1)}
      _ -> {frame.first_roll, frame.second_roll}
    end
  end

  # Get the next 1 roll, ie the first roll of this frame
  def get_next_roll(game, frame_num) do
    frame = Map.get(game, frame_num)
    frame.first_roll
  end

end
