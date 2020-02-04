defmodule AFK.Keycode.KeyTest do
  @moduledoc false

  use ExUnit.Case

  alias AFK.Keycode.Key

  doctest Key, import: true

  test "raises if non-existent key ID is given" do
    assert_raise FunctionClauseError, fn ->
      Key.new(:fake)
    end
  end
end
