defmodule AFK.State.KeymapTest do
  use ExUnit.Case

  test "empty state keymap" do
    assert %AFK.State.Keymap{} = AFK.State.Keymap.new([])
  end
end
