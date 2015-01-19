defmodule Primes.TableFormatter do
  import ExPrintf

  def display {[], []} do
  end

  def display {factors, table} do
    display_row "", factors
    display_table factors, table
  end

  defp display_table [], _table do
  end

  defp display_table [f | factors], [row | table] do
    display_row(f, row)
    display_table(factors, table)
  end

  defp display_row(header, numbers) when is_number(header) do
    display_row(sprintf("%4d", [header]), numbers)
  end

  defp display_row header, numbers do
    header = sprintf("%4s", [header])
    rest = numbers |> Enum.reduce("",
      fn (x, acc) -> "#{acc} #{sprintf("%4d ", [x])}" end
    )
    IO.puts "#{header} | #{rest}"
  end
end
