defmodule RadTest do
  use ExUnit.Case
  doctest Rad

  test "greets the world" do
    assert Rad.hello() == :world
  end
end
