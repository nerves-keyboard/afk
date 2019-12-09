defmodule AFK.Keycodes.KeyTest do
  use ExUnit.Case

  alias AFK.Keycodes.Key

  doctest Key, import: true

  test "raises if non-existent key ID is given" do
    assert_raise FunctionClauseError, fn ->
      Key.new(:fake)
    end
  end
end
