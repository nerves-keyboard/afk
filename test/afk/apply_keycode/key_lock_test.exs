defmodule AFK.ApplyKeycode.KeyLockTest do
  @moduledoc false

  use AFK.SixKeyCase, async: true

  alias AFK.Keycode.Key
  alias AFK.Keycode.KeyLock
  alias AFK.Keycode.Layer
  alias AFK.Keycode.Modifier
  alias AFK.Keycode.Transparent
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

  @moduletag keymap: @keymap

  test "pressing and releasing key lock key does nothing (at first)", %{state: state} do
    State.press_key(state, :k001)
    State.release_key(state, :k001)

    assert_hid_reports([])
  end

  test "locking and unlocking a regular key", %{state: state} do
    State.press_key(state, :k001)
    State.release_key(state, :k001)
    State.press_key(state, :k002)
    State.release_key(state, :k002)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}}
    ])

    State.press_key(state, :k002)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}}
    ])

    State.release_key(state, :k002)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}},
      %{keys: {0, 0, 0, 0, 0, 0}}
    ])
  end

  test "locking and unlocking a modifier key", %{state: state} do
    State.press_key(state, :k001)
    State.release_key(state, :k001)
    State.press_key(state, :k004)
    State.release_key(state, :k004)

    assert_hid_reports([
      %{mods: [@left_control]}
    ])

    State.press_key(state, :k004)

    assert_hid_reports([
      %{mods: [@left_control]}
    ])

    State.release_key(state, :k004)

    assert_hid_reports([
      %{mods: [@left_control]},
      %{mods: []}
    ])
  end

  test "locking while holding lock", %{state: state} do
    State.press_key(state, :k001)
    State.press_key(state, :k002)
    State.release_key(state, :k002)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}}
    ])

    State.press_key(state, :k002)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}}
    ])

    State.release_key(state, :k002)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}},
      %{keys: {0, 0, 0, 0, 0, 0}}
    ])

    State.release_key(state, :k001)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}},
      %{keys: {0, 0, 0, 0, 0, 0}}
    ])
  end

  test "locking and unlocking the same physical key on different layers", %{state: state} do
    # activate lock
    State.press_key(state, :k001)
    State.release_key(state, :k001)
    # lock 'a' on layer 0
    State.press_key(state, :k002)
    State.release_key(state, :k002)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}}
    ])

    # activate layer 1
    State.press_key(state, :k003)
    # activate lock
    State.press_key(state, :k001)
    State.release_key(state, :k001)
    # lock 'b' on layer 1
    State.press_key(state, :k002)
    State.release_key(state, :k002)
    # release layer 1
    State.release_key(state, :k003)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}},
      %{keys: {@a, @b, 0, 0, 0, 0}}
    ])

    # unlock 'a' by tapping it again
    State.press_key(state, :k002)
    State.release_key(state, :k002)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}},
      %{keys: {@a, @b, 0, 0, 0, 0}},
      %{keys: {0, @b, 0, 0, 0, 0}}
    ])

    # activate layer 1
    State.press_key(state, :k003)
    # unlock 'b' by tapping it again
    State.press_key(state, :k002)
    State.release_key(state, :k002)
    # release layer 1
    State.release_key(state, :k003)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}},
      %{keys: {@a, @b, 0, 0, 0, 0}},
      %{keys: {0, @b, 0, 0, 0, 0}},
      %{keys: {0, 0, 0, 0, 0, 0}}
    ])
  end

  test "locking a key and using the same physical key on different layer", %{state: state} do
    # activate lock
    State.press_key(state, :k001)
    State.release_key(state, :k001)
    # lock 'a' on layer 0
    State.press_key(state, :k002)
    State.release_key(state, :k002)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}}
    ])

    # activate layer 1
    State.press_key(state, :k003)
    # press 'b' on layer 1
    State.press_key(state, :k002)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}},
      %{keys: {@a, @b, 0, 0, 0, 0}}
    ])

    # release 'b' on layer 1
    State.release_key(state, :k002)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}},
      %{keys: {@a, @b, 0, 0, 0, 0}},
      %{keys: {@a, 0, 0, 0, 0, 0}}
    ])
  end

  test "locking and unlocking the same physical key (modifiers) on different layers", %{state: state} do
    # activate lock
    State.press_key(state, :k001)
    State.release_key(state, :k001)
    # lock 'left control' on layer 0
    State.press_key(state, :k004)
    State.release_key(state, :k004)

    assert_hid_reports([
      %{mods: [@left_control]}
    ])

    # activate layer 1
    State.press_key(state, :k003)
    # activate lock
    State.press_key(state, :k001)
    State.release_key(state, :k001)
    # lock 'left shift' on layer 1
    State.press_key(state, :k004)
    State.release_key(state, :k004)
    # release layer 1
    State.release_key(state, :k003)

    assert_hid_reports([
      %{mods: [@left_control]},
      %{mods: [@left_control, @left_shift]}
    ])

    # unlock 'left control' by tapping it again
    State.press_key(state, :k004)
    State.release_key(state, :k004)

    assert_hid_reports([
      %{mods: [@left_control]},
      %{mods: [@left_control, @left_shift]},
      %{mods: [@left_shift]}
    ])

    # activate layer 1
    State.press_key(state, :k003)
    # unlock 'left shift' by tapping it again
    State.press_key(state, :k004)
    State.release_key(state, :k004)
    # release layer 1
    State.release_key(state, :k003)

    assert_hid_reports([
      %{mods: [@left_control]},
      %{mods: [@left_control, @left_shift]},
      %{mods: [@left_shift]},
      %{mods: []}
    ])
  end

  test "locking and unlocking layer hold", %{state: state} do
    # activate lock
    State.press_key(state, :k001)
    State.release_key(state, :k001)
    # tap layer hold key to lock it
    State.press_key(state, :k003)
    State.release_key(state, :k003)
    # press 'b' on layer 1
    State.press_key(state, :k002)

    assert_hid_reports([
      %{keys: {@b, 0, 0, 0, 0, 0}}
    ])

    # release 'b'
    State.release_key(state, :k002)
    # tap layer 1 hold key to unlock it
    State.press_key(state, :k003)
    State.release_key(state, :k003)
    # press 'a' on layer 0
    State.press_key(state, :k002)

    assert_hid_reports([
      %{keys: {@b, 0, 0, 0, 0, 0}},
      %{keys: {0, 0, 0, 0, 0, 0}},
      %{keys: {@a, 0, 0, 0, 0, 0}}
    ])
  end

  test "tapping lock key again cancels pending lock", %{state: state} do
    # activate lock
    State.press_key(state, :k001)
    State.release_key(state, :k001)
    # tap lock key again to cancel pending lock
    State.press_key(state, :k001)
    State.release_key(state, :k001)

    # pressing and releasing key acts like normal, not locking
    State.press_key(state, :k002)
    State.release_key(state, :k002)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}},
      %{keys: {0, 0, 0, 0, 0, 0}}
    ])
  end
end
