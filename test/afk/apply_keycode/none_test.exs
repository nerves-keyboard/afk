defmodule AFK.ApplyKeycode.NoneTest do
  @moduledoc false

  use AFK.SixKeyCase, async: true

  alias AFK.Keycode.Key
  alias AFK.Keycode.None
  alias AFK.State

  @a Key.new(:a)
  @none None.new()

  @layer_0 %{
    k001: @none,
    k002: @none,
    k003: @none,
    k004: @none,
    k005: @none,
    k006: @none,
    k007: @a
  }

  @keymap [
    @layer_0
  ]

  @moduletag keymap: @keymap

  test "pressing and releasing a none keycode does nothing", %{state: state} do
    State.press_key(state, :k001)
    State.release_key(state, :k001)

    assert_hid_reports([])
  end

  test "pressing a non-existent key is treated as a none key-press", %{state: state} do
    State.press_key(state, :k010)

    assert_hid_reports([])
  end

  test "pressing 6 none keys doesn't fill up the HID buffer", %{state: state} do
    Enum.each(
      ~w(k001 k002 k003 k004 k005 k006)a,
      &State.press_key(state, &1)
    )

    # all positions are still considered open, even though 6 keys are being
    # pressed
    State.press_key(state, :k007)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}}
    ])
  end
end
