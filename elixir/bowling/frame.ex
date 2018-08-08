defmodule Bowling.Frame do
  alias __MODULE__

  defstruct [
    state: :first_roll,
    first_roll: nil,  # num of pins hit in first roll
    second_roll: nil, # num of pins hit in second roll
    third_roll: nil,  # num of pins hit in the 3rd roll (only 10th frame!)
    mark: :open,      # open, spare, or strike
    score: 0          # Score for this frame
  ]

  def new() do
    %Frame{}
  end

  def roll(_frame, roll) when roll < 0 do
    {:error, "Negative roll is invalid"}
  end

  # First roll of the frame
  def roll(%Frame{state: :first_roll} = frame, roll)
    when roll <= 10 do
      frame = %{frame | first_roll: roll}
      case roll do
        10 -> {:ok, %{frame | mark: :strike, state: :done}}
        _  -> {:ok, %{frame | state: :second_roll}}
      end
  end

  # Second roll of the frame
  def roll(%Frame{first_roll: fr, state: :second_roll} = frame, roll)
    when roll <= (10 - fr) do
      frame = %{frame | second_roll: roll, state: :done}
      cond do
        roll + fr == 10 -> {:ok, %{frame | mark: :spare}}
        true            -> {:ok, frame}
      end
  end

  #Tried to roll on a bad state
  def roll(%Frame{state: :done}, _roll) do
    {:error, "Frame finished, rolling not allowed"}
  end

  # Error case: Too many pins hit
  def roll(_frame, _roll) do
    {:error, "Pin count exceeds pins on the lane"}
  end

  # Special rules for the 10th frame!

  #First Roll of the 10th frame
  def roll_tenth(_frame, roll) when roll < 0 do
    {:error, "Negative roll is invalid"}
  end

  def roll_tenth(%Frame{state: :first_roll} = frame, roll) do
    case roll(frame, roll) do
      {:ok, %Frame{mark: :strike} = frame} -> {:ok, %{frame | state: :first_strike_fill}}
      {:ok, frame} -> {:ok, frame}
      {:error, reason} -> {:error, reason}
    end
  end

  #Second roll of the 10th frame - no strike
  def roll_tenth(%Frame{state: :second_roll} = frame, roll) do
    case roll(frame, roll) do
      {:ok, %Frame{mark: :spare} = frame} -> {:ok, %{frame | state: :spare_fill}}
      {:ok, frame} -> {:ok, frame}
      {:error, reason} -> {:error, reason}
    end
  end

  # Second roll of the tenth frame - Strike fill ball case
  def roll_tenth(%Frame{state: :first_strike_fill} = frame, roll) when roll <= 10 do
    {:ok, %{frame | second_roll: roll, state: :second_strike_fill}}
  end

  #BUG
  # Third roll of the tenth frame 2nd strike fill ball, 2nd roll was a strike
  def roll_tenth(%Frame{state: :second_strike_fill, second_roll: 10} = frame, roll)
    when roll <= 10 do
    {:ok, %{frame | third_roll: roll, state: :done}}
  end

  # Third roll of the tenth frame 2nd strike fill ball, 2nd roll wasn't a strike
  def roll_tenth(%Frame{state: :second_strike_fill, second_roll: sr} = frame, roll)
    when roll <= (10 - sr) do
    {:ok, %{frame | third_roll: roll, state: :done}}
  end

  # Third roll of the tenth frame spare fill ball
  def roll_tenth(%Frame{state: :spare_fill} = frame, roll) when roll <= 10 do
    {:ok, %{frame | third_roll: roll, state: :done}}
  end

  #Tried to roll on a bad state
  def roll_tenth(%Frame{state: :done}, _roll) do
    {:error, "Frame finished, rolling not allowed"}
  end

  def roll_tenth(_frame, _roll) do
    {:error, "Pin count exceeds pins on the lane"}
  end

  # Scoring logic
  def set_score(frame, score) do
    %{frame | score: score}
  end
end
