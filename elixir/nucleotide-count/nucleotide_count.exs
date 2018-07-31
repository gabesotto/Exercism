defmodule NucleotideCount do
  @nucleotides [?A, ?C, ?G, ?T]

  @doc """
  Counts individual nucleotides in a DNA strand.

  ## Examples

  iex> NucleotideCount.count('AATAA', ?A)
  4

  iex> NucleotideCount.count('AATAA', ?T)
  1
  """
  @spec count([char], char) :: non_neg_integer
  def count(strand, nucleotide) when nucleotide in @nucleotides do
    Enum.count(strand, fn char ->
      char == nucleotide
    end)
  end
  def count(_strand, _nucleotide), do: :invalid_nucleotide_error

  @doc """
  Returns a summary of counts by nucleotide.

  ## Examples

  iex> NucleotideCount.histogram('AATAA')
  %{?A => 4, ?T => 1, ?C => 0, ?G => 0}
  """
  @spec histogram([char]) :: map
  def histogram(strand) do
    # Go through each nucleotide and count how many are in the strand, add it to the map
    Enum.reduce(@nucleotides, %{}, fn nuc, acc ->
      count = NucleotideCount.count(strand, nuc)
      Map.put(acc, nuc, count)
    end)
  end

end
