defmodule P do
  def proc(n) do
    n
  end
  
  def run(n) do
    IO.puts(inspect(:timer.tc(Enum, :reduce, [1..n, fn x, _ -> spawn(P, :proc, [x]) end])))
  end
end


  
  
    
  
