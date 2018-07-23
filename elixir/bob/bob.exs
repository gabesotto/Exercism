defmodule Bob do
  def hey(input) do
    cond do
      question?(input) and yell?(input) -> "Calm down, I know what I'm doing!"
      question?(input) -> "Sure."
      yell?(input) -> "Whoa, chill out!"
      empty?(input) -> "Fine. Be that way!"
      true -> "Whatever."
    end
  end

  def question?(input) do
    String.last(input) == "?"
  end

  def yell?(input) do
    # remove numbers and symbols because this throws off the uppercase comparison
    input = Regex.replace(~r/[0-9]/, input, "")
    input = Regex.replace(~r/[?|,]/, input, "")
    input = String.trim(input)
    not(empty?(input)) and input == String.upcase(input)
  end

  def empty?(input) do
    String.trim(input) == ""
  end
end
