defmodule Sieve do
  @doc """
  Generates a list of primes up to a given limit.
  """
  @spec primes_to(non_neg_integer) :: [non_neg_integer]
  def primes_to(limit) do
    MapSet.new()
    |> mark_composites(2, limit)
    |> find_primes(limit)
  end

  # Find the primes in sieve, by finding everything that isnt a composite
  def find_primes(sieve, limit) do
    Enum.to_list(2..limit) -- MapSet.to_list(sieve)
  end

  # Given a sieve, mark all the of composites for each prime up to the sqrt(limit)
  def mark_composites(sieve, prime, limit) do
    # 2 to sqrt(limit) is enough prime "sieving" to hit the limit
    if(prime <= :math.sqrt(limit)) do
      sieve = mark_prime_composites(sieve, prime, limit)
      mark_composites(sieve, find_next_prime(sieve, prime), limit)
    else
      sieve
    end
  end

  # Mark all the composites for one given prime by multiplying by the multiple
  # 2p, 3p, 4p, ... until n*p <= limit
  def mark_prime_composites(sieve, prime, limit), do: mark_prime_composites(sieve, prime, 2, limit)
  def mark_prime_composites(sieve, prime, multiple, limit) when prime * multiple <= limit do
    sieve = MapSet.put(sieve, prime * multiple)
    mark_prime_composites(sieve, prime, multiple + 1, limit)
  end
  def mark_prime_composites(sieve, _prime, _multiple, _limit), do: sieve

  # Given a number, increment until we find the next prime in the sieve
  def find_next_prime(sieve, num) do
    num = num + 1
    if (MapSet.member?(sieve, num)) do
      find_next_prime(sieve, num)
    else
      num
    end
  end

end
