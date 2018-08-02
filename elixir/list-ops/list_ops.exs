defmodule ListOps do
  # Please don't use any external modules (especially List) in your
  # implementation. The point of this exercise is to create these basic functions
  # yourself.
  #
  # Note that `++` is a function from an external module (Kernel, which is
  # automatically imported) and so shouldn't be used either.

  @spec count(list) :: non_neg_integer
  def count(l) do
    _count(l, 0)
  end

  defp _count([_h | t], acc) do
    _count(t, acc + 1)
  end

  defp _count([], acc) do
    acc
  end

  @spec reverse(list) :: list
  def reverse(l) do
    _reverse(l, [])
  end

  defp _reverse([h | t], acc) do
    _reverse(t, [h | acc])
  end

  defp _reverse([], acc) do
    acc
  end

  #  NOTE: a body recursive map might be more efficent because I have to reverse
  #  the final result, but I'm doing this whole excersize with tail call optimization.
  @spec map(list, (any -> any)) :: list
  def map(l, f) do
    _map(l, [], f)
  end

  defp _map([h | t], acc, f) do
    _map(t, [f.(h) | acc], f)
  end

  defp _map([], acc, _f) do
    reverse(acc)
  end

  # NOTE: Same note as above for map but for filter this time
  @spec filter(list, (any -> as_boolean(term))) :: list
  def filter(l, f) do
    _filter(l, [], f)
  end

  defp _filter([h | t], acc, f) do
    cond do
      f.(h) -> _filter(t, [h | acc], f)
      true  -> _filter(t, acc, f)
    end
  end

  defp _filter([], acc, _f) do
    reverse(acc)
  end

  @type acc :: any
  @spec reduce(list, acc, (any, acc -> acc)) :: acc
  def reduce([h | t], acc, f) do
    reduce(t, f.(h, acc), f)
  end

  def reduce([], acc, _f) do
    acc
  end

  @spec append(list, list) :: list
  def append(a, b) do
    _append(reverse(a), b)
  end

  defp _append([h | t], acc) do
    _append(t, [h | acc])
  end

  defp _append([], acc) do
    acc
  end

  @spec concat([[any]]) :: [any]
  def concat(ll) do
    reduce(ll, [], &(append(&2, &1)))
  end
end
