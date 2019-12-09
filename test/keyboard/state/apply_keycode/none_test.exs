defmodule AFK.State.ApplyKeycode.NoneTest do
  use AFK.KeycodeCase

  alias AFK.State
  alias AFK.Keycodes.{Key, None}

  @a Key.new(:a)
  @none %None{}

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

  test "pressing and releasing a none keycode does nothing" do
    state =
      @keymap
      |> State.new()
      |> State.press_key(:k001)

    assert_6kr(state, [0, 0, 0, 0, 0, 0])

    state = State.release_key(state, :k001)

    assert_6kr(state, [0, 0, 0, 0, 0, 0])
  end

  test "pressing a non-existent key is treated as a none key-press" do
    state =
      @keymap
      |> State.new()
      |> State.press_key(:k010)

    assert_6kr(state, [0, 0, 0, 0, 0, 0])
  end

  test "pressing 6 none keys doesn't fill up the HID buffer" do
    state =
      Enum.reduce(
        ~w(k001 k002 k003 k004 k005 k006)a,
        State.new(@keymap),
        &State.press_key(&2, &1)
      )

    assert_6kr(state, [0, 0, 0, 0, 0, 0])

    # all positions are still considered open, even though 6 keys are being
    # pressed
    state = State.press_key(state, :k007)
    assert_6kr(state, [@a, 0, 0, 0, 0, 0])
  end
end
