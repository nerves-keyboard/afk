defmodule AFK.KeymapTest do
  use ExUnit.Case

  test "saves a keymap to a file and then loads it back" do
    keymap = [%{k001: AFK.Keycode.Key.new(:a)}]

    assert :ok = AFK.Keymap.save_to_file!(keymap, "test_keymap.etf")
    assert ^keymap = AFK.Keymap.load_from_file!("test_keymap.etf")

    File.rm!("test_keymap.etf")
  end
end
