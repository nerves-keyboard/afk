defmodule AFK.State.KeymapTest do
  @moduledoc false

  use ExUnit.Case

  alias AFK.State.Keymap

  test "empty state keymap" do
    assert %Keymap{} = Keymap.new([])
  end
end
