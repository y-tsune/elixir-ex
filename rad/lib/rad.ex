defmodule Rad do
  @moduledoc """
  Documentation for Rad.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Rad.hello()
      :world

  """
  def fact(0) do
    1
  end
  def fact(n) do
    n*fact(n-1)
  end
  def map(l) do
    l
    |> Flow.from_enumerable
    |> Flow.map(&fact(&1))
    |> Enum.to_list
  end
  def sort(l, 0, _) do
    l
  end

  def sort(l, n, i) do
    l
    |> Flow.from_enumerable(stages: 8)
    |> Flow.group_by(fn x -> rem(Kernel.trunc(x / i), 10) end)
    |> Enum.flat_map(fn {_, v} -> v end)
    |> Flow.from_enumerable(stages: 8)
    |> Flow.group_by(fn x -> rem(Kernel.trunc(x / (i*10)), 10) end)
    |> Enum.flat_map(fn {_, v} -> v end)
    # |> Flow.flat_map(fn {_, v} -> v end)
    # |> Flow.partition
    # |> Flow.group_by(fn x -> rem(Kernel.trunc(x / i*10), 10) end)
    # |> Enum.to_list

    # |> sort(n-1, i*10)
  end

  def run(n) do
    x = Kernel.trunc :math.pow(10, n)
    l = Enum.map(1..x, fn _ -> Kernel.trunc :rand.uniform * x end)
    :timer.tc(Rad, :sort, [l, n, 1])
    |> inspect
    |> IO.puts
  end
end
