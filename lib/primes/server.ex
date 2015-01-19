# Implements a primes number server according to erlang OTP specification
defmodule Primes.Server do
  use GenServer

  @proc_name :"Primes.Primes.Provider"

  def start_link do
    # Seed primes cache with 4 numbers on server startup
    state = %{last_index: -1, next_int: 1, primes: %{}}
    |> append_prime(2)
    |> append_prime(3)
    |> append_prime(5)
    |> append_prime(7)

    GenServer.start_link __MODULE__, state, [name: @proc_name]
  end

  @doc """
    Client wrapper function for getting n-th (zero-based) prime number

    iex> Server.start_link
    ...> assert Server.get(0)
    2

    iex> Server.start_link
    ...> assert Server.get(99)
    541

    iex> Server.start_link
    ...> assert Server.get(-1)
    ** (RuntimeError) n should be >= 0
  """
  def get n do
    case GenServer.call @proc_name, {:get, n} do
      {:ok, p} -> p
      {:error, reason} -> raise reason
    end
  end

  @doc """
    Produces infinite, lazy-evaluated prime numbers stream

    iex> Primes.Server.start_link
    ...> Server.as_stream
    ...>   |> Enum.take(10)
    ...>   |> Enum.to_list
    [2,3,5,7,11,13,17,19,23,29]
  """
  def as_stream do
    Stream.resource(
    fn -> 0 end,
    fn n -> {[get(n)], n + 1} end,
    fn _ -> end
    )
  end

  def handle_call({:get, n}, _from, state) when n < 0 do
    {:reply, {:error, "n should be >= 0"}, state}
  end

  # Complexity: O(1)
  def handle_call({:get, n}, _from, %{last_index: last_index, primes: primes} = state)
  when last_index >= n do

    {:reply, {:ok, Map.get(primes, n)}, state}
  end

  @doc """
  Complexity:
    O(handle_call) = Sum(sqrt(x) / log(sqrt(x)))
      for x = next_int, next_int + 2, ..., p
      where p is the prime
  """
  def handle_call({:get, n}, _from, %{next_int: next_int, primes: primes} = state) do
    p = next_prime(next_int, Dict.values(primes))
    handle_call {:get, n}, _from, append_prime(state, p)
  end

  defp append_prime(%{primes: primes, last_index: last_index}, prime)
  when is_number(prime) do

    %{
      primes: Dict.put(primes, last_index + 1, prime),
      last_index: last_index + 1,
      next_int: prime + 2
    }
  end

  # Practically this clause should never match. It's here only for consistency
  defp next_prime(start_from, known_primes) when rem(start_from, 2) == 0 do
    next_prime(start_from + 1, known_primes)
  end

  defp next_prime start_from, known_primes do
    if is_prime(start_from, known_primes) do
      start_from
    else
      next_prime start_from + 2, known_primes
    end
  end

  # If n % p == 0 -> n is not a prime
  defp is_prime(n, [p | _primes]) when rem(n,p) == 0 do false end

  # If n doesn't divide any prime below sqrt(n), then n is a prime
  defp is_prime(n, [p | _primes]) when n < p * p do true end

  # In this case n % p != 0. Test if next prime divides n
  #
  # Complexity: (according to https://primes.utm.edu/howmany.html)
  #   Omega(is_prime(n)) = pi(sqrt(n)) ~
  #     sqrt(n) / log(sqrt(n))
  #
  # O(is_prime(n)) will be much less than Omega(is_prime(n)), as most
  #   of the integers will have prime dividors
  defp is_prime(n, [_p | primes]), do: is_prime(n, primes)
end
