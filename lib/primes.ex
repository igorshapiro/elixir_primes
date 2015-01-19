Primes.Server.start_link

primes = Primes.Server.as_stream |> Enum.take(10)
{primes, Primes.MultiplicationTable.build(primes)}
  |> Primes.TableFormatter.display
