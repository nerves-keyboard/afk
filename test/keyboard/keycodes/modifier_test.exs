defmodule AFK.Keycodes.ModifierTest do
  use ExUnit.Case

  alias AFK.Keycodes.Modifier

  doctest Modifier, import: true

  test "raises if non-existent modifier ID is given" do
    assert_raise FunctionClauseError, fn ->
      Modifier.new(:fake)
    end
  end
end
