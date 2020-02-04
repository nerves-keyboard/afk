defmodule AFK.KeymapTest do
  @moduledoc false

  use ExUnit.Case

  alias AFK.Keycode.Key
  alias AFK.Keymap

  test "saves a keymap to a file and then loads it back" do
    keymap = [%{k001: Key.new(:a)}]

    assert :ok = Keymap.save_to_file!(keymap, "test_keymap.etf")
    assert ^keymap = Keymap.load_from_file!("test_keymap.etf")

    File.rm!("test_keymap.etf")
  end
end
