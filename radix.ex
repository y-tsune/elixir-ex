defmodule RadixSort do
  def sort(l, 0, _) do
    l
  end
  
  def sort(l, n, i) do
    l
    |> Enum.group_by(fn x -> Integer.mod(floor(x / i), 10) end)
    |> Enum.flat_map(fn {_, v} -> v end)
    |> sort(n-1, i*10)
  end
  
  def run(n) do
    x = floor :math.pow(10, n)
    l = Enum.map(1..x, fn _ -> floor :rand.uniform * x end)
    :timer.tc(RadixSort, :sort, [l, n, 1])
    |> inspect
    |> IO.puts
  end

  # --------------------
  # PARALLEL
  # --------------------

  def run_par(n) do
    x = floor :math.pow(10, n)
    m = Enum.reduce 0..9, %{}, fn key, acc -> Map.put acc, key, 0 end
    l = Enum.map(1..x, fn _ -> floor :rand.uniform * x end)
    :timer.tc(RadixSort, :sort_par, [l, n, 1, m, x])
    |> inspect
    |> IO.puts
  end

  def sort_par(l, 0, _, _, _) do
    Enum.reverse(l)
  end

  def sort_par(l, n, i, m, x) do
    sort_body(l, m, i, x)
    |> Enum.reverse
    |> sort_par(n-1, i*10, m, x)
  end

  def insert_bucket(parent, l, key) do
    receive do
      :end -> send parent, {key, l}
      x -> RadixSort.insert_bucket(parent, [x | l], key)
    end
  end
  
  def sup_of_insert(parent, 0) do
    send parent, {self(), :end}
  end

  def sup_of_insert(parent, n) do
    receive do
      :end -> RadixSort.sup_of_insert(parent, n-1)
    end
  end
  
  def merg(parent, 0, m) do
    send parent, {self(), m}
  end

  def merg(parent, n, m) do
    receive do
      {key, x} -> RadixSort.merg(parent, n-1, Map.put(m, key, x))
    end
  end
  
  def sort_body(l, r, i, size) do
    me = self()
    sup = spawn(RadixSort, :sup_of_insert, [me, size])
    merg = spawn(RadixSort, :merg, [me, 10, r])
    m = Enum.reduce 0..9, %{}, fn key, acc ->
      Map.put acc, key, spawn(RadixSort, :insert_bucket, [merg, [], key])
    end
    Enum.map l, fn x ->
      spawn(fn ->
	send m[Integer.mod(floor(x / i), 10)], x
	send sup, :end
      end)
    end
    receive do
      {^sup, :end} -> Enum.map m, fn {_, pid} -> send pid, :end end
    end
    receive do
      {^merg, l} -> Enum.flat_map l, fn {_, v} -> v end
    end
  end
end
