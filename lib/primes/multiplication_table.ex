defmodule Primes.MultiplicationTable do
  @doc """
    iex> Primes.MultiplicationTable.build [2,3]
    [[4,6], [6,9]]
  """
  def build numbers do
    numbers |>
      Enum.map(fn n -> build_row(n, numbers) end)
  end

  def build_row n, numbers do
    numbers |> Enum.map(fn x -> x * n end)
  end
end
