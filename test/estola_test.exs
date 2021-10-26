defmodule EstolaTest do
  use ExUnit.Case
  doctest Estola

  test "greets the world" do
    assert Estola.hello() == :world
  end
end
