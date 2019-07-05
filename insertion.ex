defmodule Insertion do
  def insert(l, x) do
    case l do
      [h | hs] -> if x < h, do: [x | l], else: [h | insert(hs, x)]
      [] -> [x]
      _ -> inspect l
    end
  end

  def insertion_sort(l, x, []) do
    insert(l, x)
  end

  def insertion_sort(l, x, [y | ys]) do
    insert(l, x)
    |> insertion_sort(y, ys)
  end

  def sort(l) do
    case l do
      [] -> l
      [_] -> l
      [x | [y | xs]] -> insertion_sort([y], x, xs)
    end
  end
  

  #
  # Parallel
  #

  def send_to_next(x, y, :end) do
    insert_par(x, spawn(Insertion, :insert_par, [y, :end]))
  end
  
  def send_to_next(x, y, p) do
    send p, y
    insert_par(x, p)
  end

  def insert_par(x, next) do
    receive do
      {:ret, p} -> send p, {x, next}
      y -> if x < y, do: send_to_next(x, y, next), else: send_to_next(y, x, next)
    end
  end

  def insertion_sort_par([], _) do
    
  end

  def insertion_sort_par([x | xs], p) do
    send p, x
    insertion_sort_par(xs, p)
  end
  
  def ret_val(l, p) do
    send p, {:ret, self()}
    receive do
      {x, :end} -> [x | l]
      {x, next} -> ret_val([x | l], next)
    end
  end

  def sort_par([]) do
    []
  end
  
  def sort_par([x | xs]) do
    root = spawn(Insertion, :insert_par, [x, :end])
    IO.puts inspect :timer.tc(Insertion, :insertion_sort_par, [xs, root])
    ret_val([], root)
    |> Enum.reverse
  end

  def run(n) do
    x = floor :math.pow(10, n)
    l = Enum.map(1..x, fn _ -> floor :rand.uniform * x end)
    :timer.tc(Insertion, :sort_par, [l])
    |> inspect
    |> IO.puts
  end
  
end
