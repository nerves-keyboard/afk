defmodule AFK.ApplyKeycode.KeyLockTest do
  use AFK.KeycodeCase

  alias AFK.Keycode.{Key, KeyLock, Layer, Modifier, Transparent}
  alias AFK.State

  @a Key.new(:a)
  @b Key.new(:b)
  @key_lock KeyLock.new()
  @hold_for_layer_1 Layer.new(:hold, 1)
  @transparent Transparent.new()
  @left_control Modifier.new(:left_control)
  @left_shift Modifier.new(:left_shift)

  @layer_0 %{
    k001: @key_lock,
    k002: @a,
    k003: @hold_for_layer_1,
    k004: @left_control
  }

  @layer_1 %{
    k001: @transparent,
    k002: @b,
    k003: @transparent,
    k004: @left_shift
  }

  @keymap [
    @layer_0,
    @layer_1
  ]

  test "pressing and releasing key lock key does nothing (at first)" do
    state =
      @keymap
      |> State.new()
      |> State.press_key(:k001)

    assert_6kr(state, [0, 0, 0, 0, 0, 0])

    state = State.release_key(state, :k001)

    assert_6kr(state, [0, 0, 0, 0, 0, 0])
  end

  test "locking and unlocking a regular key" do
    state =
      @keymap
      |> State.new()
      |> State.press_key(:k001)
      |> State.release_key(:k001)
      |> State.press_key(:k002)
      |> State.release_key(:k002)

    assert_6kr(state, [@a, 0, 0, 0, 0, 0])

    state = State.press_key(state, :k002)

    assert_6kr(state, [@a, 0, 0, 0, 0, 0])

    state = State.release_key(state, :k002)

    assert_6kr(state, [0, 0, 0, 0, 0, 0])
  end

  test "locking and unlocking a modifier key" do
    state =
      @keymap
      |> State.new()
      |> State.press_key(:k001)
      |> State.release_key(:k001)
      |> State.press_key(:k004)
      |> State.release_key(:k004)

    assert_modifiers(state, [@left_control])

    state = State.press_key(state, :k004)

    assert_modifiers(state, [@left_control])

    state = State.release_key(state, :k004)

    assert_modifiers(state, [])
  end

  test "locking while holding lock" do
    state =
      @keymap
      |> State.new()
      |> State.press_key(:k001)
      |> State.press_key(:k002)
      |> State.release_key(:k002)

    assert_6kr(state, [@a, 0, 0, 0, 0, 0])

    state = State.press_key(state, :k002)

    assert_6kr(state, [@a, 0, 0, 0, 0, 0])

    state = State.release_key(state, :k002)

    assert_6kr(state, [0, 0, 0, 0, 0, 0])

    state = State.release_key(state, :k001)

    assert_6kr(state, [0, 0, 0, 0, 0, 0])
  end

  test "locking and unlocking the same physical key on different layers" do
    state =
      @keymap
      |> State.new()
      # activate lock
      |> State.press_key(:k001)
      |> State.release_key(:k001)
      # lock 'a' on layer 0
      |> State.press_key(:k002)
      |> State.release_key(:k002)

    assert_6kr(state, [@a, 0, 0, 0, 0, 0])

    state =
      state
      # activate layer 1
      |> State.press_key(:k003)
      # activate lock
      |> State.press_key(:k001)
      |> State.release_key(:k001)
      # lock 'b' on layer 1
      |> State.press_key(:k002)
      |> State.release_key(:k002)
      # release layer 1
      |> State.release_key(:k003)

    assert_6kr(state, [@a, @b, 0, 0, 0, 0])

    state =
      state
      # unlock 'a' by tapping it again
      |> State.press_key(:k002)
      |> State.release_key(:k002)

    assert_6kr(state, [0, @b, 0, 0, 0, 0])

    state =
      state
      # activate layer 1
      |> State.press_key(:k003)
      # unlock 'b' by tapping it again
      |> State.press_key(:k002)
      |> State.release_key(:k002)
      # release layer 1
      |> State.release_key(:k003)

    assert_6kr(state, [0, 0, 0, 0, 0, 0])
  end

  test "locking a key and using the same physical key on different layer" do
    state =
      @keymap
      |> State.new()
      # activate lock
      |> State.press_key(:k001)
      |> State.release_key(:k001)
      # lock 'a' on layer 0
      |> State.press_key(:k002)
      |> State.release_key(:k002)

    assert_6kr(state, [@a, 0, 0, 0, 0, 0])

    state =
      state
      # activate layer 1
      |> State.press_key(:k003)
      # press 'b' on layer 1
      |> State.press_key(:k002)

    assert_6kr(state, [@a, @b, 0, 0, 0, 0])

    # release 'b' on layer 1
    state = State.release_key(state, :k002)

    assert_6kr(state, [@a, 0, 0, 0, 0, 0])
  end

  test "locking and unlocking the same physical key (modifiers) on different layers" do
    state =
      @keymap
      |> State.new()
      # activate lock
      |> State.press_key(:k001)
      |> State.release_key(:k001)
      # lock 'left control' on layer 0
      |> State.press_key(:k004)
      |> State.release_key(:k004)

    assert_modifiers(state, [@left_control])

    state =
      state
      # activate layer 1
      |> State.press_key(:k003)
      # activate lock
      |> State.press_key(:k001)
      |> State.release_key(:k001)
      # lock 'left shift' on layer 1
      |> State.press_key(:k004)
      |> State.release_key(:k004)
      # release layer 1
      |> State.release_key(:k003)

    assert_modifiers(state, [@left_control, @left_shift])

    state =
      state
      # unlock 'left control' by tapping it again
      |> State.press_key(:k004)
      |> State.release_key(:k004)

    assert_modifiers(state, [@left_shift])

    state =
      state
      # activate layer 1
      |> State.press_key(:k003)
      # unlock 'left shift' by tapping it again
      |> State.press_key(:k004)
      |> State.release_key(:k004)
      # release layer 1
      |> State.release_key(:k003)

    assert_modifiers(state, [])
  end

  test "locking and unlocking layer hold" do
    state =
      @keymap
      |> State.new()
      # activate lock
      |> State.press_key(:k001)
      |> State.release_key(:k001)
      # tap layer hold key to lock it
      |> State.press_key(:k003)
      |> State.release_key(:k003)
      # press 'b' on layer 1
      |> State.press_key(:k002)

    assert_6kr(state, [@b, 0, 0, 0, 0, 0])

    state =
      state
      # release 'b'
      |> State.release_key(:k002)
      # tap layer 1 hold key to unlock it
      |> State.press_key(:k003)
      |> State.release_key(:k003)
      # press 'a' on layer 0
      |> State.press_key(:k002)

    assert_6kr(state, [@a, 0, 0, 0, 0, 0])
  end

  test "tapping lock key again cancels pending lock" do
    state =
      @keymap
      |> State.new()
      # activate lock
      |> State.press_key(:k001)
      |> State.release_key(:k001)
      # tap lock key again to cancel pending lock
      |> State.press_key(:k001)
      |> State.release_key(:k001)

    # assert it's not locked, and the lock is not pending
    refute state.pending_lock?
    assert [] = state.locked_keys
  end
end
