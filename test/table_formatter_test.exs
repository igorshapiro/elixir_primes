defmodule TableFormatterTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  test "formatted table output" do
    assert capture_io(fn ->
      Primes.TableFormatter.display {[1,2,3], [[4,5,6],[7,8,9],[10,11,12]]}
    end) ==
    "     |     1     2     3 \n" <>
    "   1 |     4     5     6 \n" <>
    "   2 |     7     8     9 \n" <>
    "   3 |    10    11    12 \n"
  end
end
