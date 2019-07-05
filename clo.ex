defmodule C do
  def run do
    m = %{0 => 0, 1 => 0}
    me = self()
    spawn(fn ->
      IO.puts inspect m[0] + 1
    end)
    inspect m
  end
end
