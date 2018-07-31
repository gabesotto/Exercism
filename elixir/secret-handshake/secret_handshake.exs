defmodule SecretHandshake do
  use Bitwise

  @bits [
    {1, ["wink"]},
    {2, ["double blink"]},
    {4, ["close your eyes"]},
    {8, ["jump"]}
  ]
  @doc """
  Determine the actions of a secret handshake based on the binary
  representation of the given `code`.

  If the following bits are set, include the corresponding action in your list
  of commands, in order from lowest to highest.

  1 = wink
  10 = double blink
  100 = close your eyes
  1000 = jump

  10000 = Reverse the order of the operations in the secret handshake
  """
  @spec commands(code :: integer) :: list(String.t())
  def commands(code) do
    # Go through each bit and append the command if it is a match
    commands =
      Enum.reduce(@bits, [], fn {bit, action}, acc ->
      if (bit &&& code) > 0 do
        acc ++ action
      else
        acc
      end
    end)

    # Check our final bit to see if we need to reverse
    if ((16 &&& code) > 0) do
      Enum.reverse(commands)
    else
      commands
    end
  end

end
