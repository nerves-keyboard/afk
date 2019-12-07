defmodule Keyboard.Keycodes.KeyTest do
  use ExUnit.Case

  alias Keyboard.Keycodes.Key

  doctest Key, import: true

  test "raises if non-existent key ID is given" do
    assert_raise RuntimeError, fn ->
      Key.from_id!(:fake)
    end
  end
end
