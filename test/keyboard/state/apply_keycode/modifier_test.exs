defmodule Keyboard.State.ApplyKeycode.ModifierTest do
  use Keyboard.KeycodeCase

  alias Keyboard.State
  alias Keyboard.Keycodes.Modifier

  @left_control Modifier.from_id!(:left_control)
  @left_shift Modifier.from_id!(:left_shift)
  @left_alt Modifier.from_id!(:left_alt)
  @left_super Modifier.from_id!(:left_super)
  @right_control Modifier.from_id!(:right_control)
  @right_shift Modifier.from_id!(:right_shift)
  @right_alt Modifier.from_id!(:right_alt)
  @right_super Modifier.from_id!(:right_super)

  @layer_0 %{
    k001: @left_control,
    k002: @left_shift,
    k003: @left_alt,
    k004: @left_super,
    k005: @right_control,
    k006: @right_shift,
    k007: @right_alt,
    k008: @right_super,
    k009: @left_control
  }

  @keymap [
    @layer_0
  ]

  test "press and release left control" do
    state = @keymap |> State.new() |> State.press_key(:k001)
    assert_modifiers(state, [@left_control])

    state = State.release_key(state, :k001)
    assert_modifiers(state, [])
  end

  test "activating the same modifier using two different physical keys" do
    state =
      @keymap
      |> State.new()
      |> State.press_key(:k001)
      |> State.press_key(:k009)

    # left control is active
    assert_modifiers(state, [@left_control])

    # releasing the second instance of left control doesn't release it
    state = State.release_key(state, :k009)
    assert_modifiers(state, [@left_control])

    # releasing the original instance of left control releases it
    state = State.release_key(state, :k001)
    assert_modifiers(state, [])
  end

  test "press and release multiple modifiers" do
    state =
      @keymap
      |> State.new()
      |> State.press_key(:k001)
      |> State.press_key(:k002)
      |> State.press_key(:k007)
      |> State.press_key(:k008)

    assert_modifiers(state, [@left_control, @left_shift, @right_alt, @right_super])

    state =
      state
      |> State.release_key(:k002)
      |> State.release_key(:k007)

    assert_modifiers(state, [@left_control, @right_super])
  end
end
