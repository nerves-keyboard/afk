defmodule AFK.ApplyKeycode.TapKeyTest do
  @moduledoc false

  use AFK.SixKeyCase, async: true

  alias AFK.Keycode.Key
  alias AFK.Keycode.KeyLock
  alias AFK.Keycode.Modifier
  alias AFK.Keycode.TapKey
  alias AFK.State

  @a Key.new(:a)
  @b Key.new(:b)
  @c Key.new(:c)
  @left_shift Modifier.new(:left_shift)
  @tap_key TapKey.new(@left_shift, @a, 10)
  @key_lock KeyLock.new()

  @layer_0 %{
    k001: @tap_key,
    k002: @b,
    k003: @c,
    k004: @key_lock
  }

  @keymap [
    @layer_0
  ]

  @moduletag keymap: @keymap

  defp tap(state, key) do
    State.press_key(state, key)
    Process.sleep(1)
    State.release_key(state, key)
    Process.sleep(1)
  end

  defp hold(state, key) do
    State.press_key(state, key)
    Process.sleep(20)
    State.release_key(state, key)
    Process.sleep(1)
  end

  test "tapping the key produces an 'a'", %{state: state} do
    tap(state, :k001)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}},
      %{keys: {0, 0, 0, 0, 0, 0}}
    ])
  end

  test "holding the key produces 'left shift'", %{state: state} do
    hold(state, :k001)

    assert_hid_reports([
      %{mods: [@left_shift]},
      %{mods: []}
    ])
  end

  test "quickly pressing multiple keys resulting in hold variant", %{state: state} do
    State.press_key(state, :k001)
    State.press_key(state, :k002)
    State.press_key(state, :k003)

    Process.sleep(20)

    State.release_key(state, :k001)
    State.release_key(state, :k002)
    State.release_key(state, :k003)

    assert_hid_reports([
      %{keys: {0, 0, 0, 0, 0, 0}, mods: [@left_shift]},
      %{keys: {@b, 0, 0, 0, 0, 0}, mods: [@left_shift]},
      %{keys: {@b, @c, 0, 0, 0, 0}, mods: [@left_shift]},
      %{keys: {@b, @c, 0, 0, 0, 0}, mods: []},
      %{keys: {0, @c, 0, 0, 0, 0}, mods: []},
      %{keys: {0, 0, 0, 0, 0, 0}, mods: []}
    ])
  end

  test "using it like shift to type in caps", %{state: state} do
    State.press_key(state, :k001)

    tap(state, :k002)
    tap(state, :k003)

    Process.sleep(15)

    State.release_key(state, :k001)

    assert_hid_reports([
      %{keys: {0, 0, 0, 0, 0, 0}, mods: [@left_shift]},
      %{keys: {@b, 0, 0, 0, 0, 0}, mods: [@left_shift]},
      %{keys: {0, 0, 0, 0, 0, 0}, mods: [@left_shift]},
      %{keys: {@c, 0, 0, 0, 0, 0}, mods: [@left_shift]},
      %{keys: {0, 0, 0, 0, 0, 0}, mods: [@left_shift]},
      %{keys: {0, 0, 0, 0, 0, 0}, mods: []}
    ])
  end

  test "quickly pressing multiple keys resulting in tap variant", %{state: state} do
    State.press_key(state, :k001)
    State.press_key(state, :k002)
    State.press_key(state, :k003)

    Process.sleep(1)

    State.release_key(state, :k001)
    State.release_key(state, :k002)
    State.release_key(state, :k003)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}, mods: []},
      %{keys: {@a, @b, 0, 0, 0, 0}, mods: []},
      %{keys: {@a, @b, @c, 0, 0, 0}, mods: []},
      %{keys: {0, @b, @c, 0, 0, 0}, mods: []},
      %{keys: {0, 0, @c, 0, 0, 0}, mods: []},
      %{keys: {0, 0, 0, 0, 0, 0}, mods: []}
    ])
  end

  test "pressing multiple keys resulting in tap variant", %{state: state} do
    State.press_key(state, :k001)
    Process.sleep(1)
    State.press_key(state, :k002)
    Process.sleep(1)
    State.press_key(state, :k003)

    Process.sleep(1)

    State.release_key(state, :k001)
    Process.sleep(1)
    State.release_key(state, :k002)
    Process.sleep(1)
    State.release_key(state, :k003)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}, mods: []},
      %{keys: {@a, @b, 0, 0, 0, 0}, mods: []},
      %{keys: {@a, @b, @c, 0, 0, 0}, mods: []},
      %{keys: {0, @b, @c, 0, 0, 0}, mods: []},
      %{keys: {0, 0, @c, 0, 0, 0}, mods: []},
      %{keys: {0, 0, 0, 0, 0, 0}, mods: []}
    ])
  end

  test "locking then unlocking the tap variant", %{state: state} do
    tap(state, :k004)

    tap(state, :k001)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}, mods: []}
    ])

    tap(state, :k001)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}, mods: []},
      %{keys: {0, 0, 0, 0, 0, 0}, mods: []}
    ])
  end

  test "locking then unlocking the hold variant", %{state: state} do
    tap(state, :k004)

    hold(state, :k001)

    assert_hid_reports([
      %{keys: {0, 0, 0, 0, 0, 0}, mods: [@left_shift]}
    ])

    hold(state, :k001)

    assert_hid_reports([
      %{keys: {0, 0, 0, 0, 0, 0}, mods: [@left_shift]},
      %{keys: {0, 0, 0, 0, 0, 0}, mods: []}
    ])
  end

  test "locking the tap variant, then using the hold variant while the tap is locked", %{state: state} do
    tap(state, :k004)

    tap(state, :k001)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}, mods: []}
    ])

    hold(state, :k001)

    assert_hid_reports([
      %{keys: {@a, 0, 0, 0, 0, 0}, mods: []},
      %{keys: {@a, 0, 0, 0, 0, 0}, mods: [@left_shift]},
      %{keys: {@a, 0, 0, 0, 0, 0}, mods: []}
    ])
  end

  test "locking the hold variant, then using the tap variant while the hold is locked", %{state: state} do
    tap(state, :k004)

    hold(state, :k001)

    assert_hid_reports([
      %{keys: {0, 0, 0, 0, 0, 0}, mods: [@left_shift]}
    ])

    tap(state, :k001)

    assert_hid_reports([
      %{keys: {0, 0, 0, 0, 0, 0}, mods: [@left_shift]},
      %{keys: {@a, 0, 0, 0, 0, 0}, mods: [@left_shift]},
      %{keys: {0, 0, 0, 0, 0, 0}, mods: [@left_shift]}
    ])
  end

  test "locking and unlocking both variants at the same time", %{state: state} do
    tap(state, :k004)

    hold(state, :k001)

    tap(state, :k004)

    tap(state, :k001)

    assert_hid_reports([
      %{keys: {0, 0, 0, 0, 0, 0}, mods: [@left_shift]},
      %{keys: {@a, 0, 0, 0, 0, 0}, mods: [@left_shift]}
    ])

    tap(state, :k001)

    hold(state, :k001)

    assert_hid_reports([
      %{keys: {0, 0, 0, 0, 0, 0}, mods: [@left_shift]},
      %{keys: {@a, 0, 0, 0, 0, 0}, mods: [@left_shift]},
      %{keys: {0, 0, 0, 0, 0, 0}, mods: [@left_shift]},
      %{keys: {0, 0, 0, 0, 0, 0}, mods: []}
    ])
  end
end
