defmodule AFK.ApplyKeycode.KeyTest do
  @moduledoc false

  use AFK.SixKeyCase, async: true

  alias AFK.Keycode.Key
  alias AFK.State

  @a Key.new(:a)
  @s Key.new(:s)
  @d Key.new(:d)
  @f Key.new(:f)
  @g Key.new(:g)
  @h Key.new(:h)
  @j Key.new(:j)
  @k Key.new(:k)
  @l Key.new(:l)

  @layer_0 %{
    k001: @a,
    k002: @s,
    k003: @d,
    k004: @f,
    k005: @g,
    k006: @h,
    k007: @j,
    k008: @k,
    k009: @l,
    k010: @a
  }

  @keymap [
    @layer_0
  ]

  @moduletag keymap: @keymap

  test "press and release a", %{state: state} do
    State.press_key(state, :k001)
    State.release_key(state, :k001)

    assert_hid_reports [
      %{keys: {@a, 0, 0, 0, 0, 0}},
      %{keys: {0, 0, 0, 0, 0, 0}}
    ]
  end

  test "activating the same keycode using two different physical keys", %{state: state} do
    State.press_key(state, :k001)
    # a is only pressed once
    State.press_key(state, :k010)
    # releasing the second instance of a doesn't release a
    State.release_key(state, :k010)
    # releasing the original instance of a releases it
    State.release_key(state, :k001)

    assert_hid_reports [
      %{keys: {@a, 0, 0, 0, 0, 0}},
      # Because no state is changing with the second press of @a, no new events
      # are sent.
      %{keys: {0, 0, 0, 0, 0, 0}}
    ]
  end

  test "pressing more than 6 keys causes later presses to be ignored", %{state: state} do
    Enum.each(
      ~w(k001 k002 k003 k004 k005 k006 k007 k008 k009)a,
      &State.press_key(state, &1)
    )

    assert_hid_reports [
      %{keys: {@a, 0, 0, 0, 0, 0}},
      %{keys: {@a, @s, 0, 0, 0, 0}},
      %{keys: {@a, @s, @d, 0, 0, 0}},
      %{keys: {@a, @s, @d, @f, 0, 0}},
      %{keys: {@a, @s, @d, @f, @g, 0}},
      %{keys: {@a, @s, @d, @f, @g, @h}}
      # The 6-key HID buffer is full and cannot express that j, k, and l are
      # also all being pressed. No further HID report events are sent.
    ]
  end

  test "HID buffer ordering", %{state: state} do
    Enum.each(
      ~w(k001 k002 k003 k004 k005 k006 k007 k008 k009)a,
      &State.press_key(state, &1)
    )

    Enum.each(
      ~w(k002 k004 k006)a,
      &State.release_key(state, &1)
    )

    State.release_key(state, :k007)
    State.press_key(state, :k007)

    assert_hid_reports [
      # press k001 - k009
      %{keys: {@a, 0, 0, 0, 0, 0}},
      %{keys: {@a, @s, 0, 0, 0, 0}},
      %{keys: {@a, @s, @d, 0, 0, 0}},
      %{keys: {@a, @s, @d, @f, 0, 0}},
      %{keys: {@a, @s, @d, @f, @g, 0}},
      %{keys: {@a, @s, @d, @f, @g, @h}},
      # release k002, k004, k006 (the released keys free up new spots, but the
      # other held keys do not fill them)
      %{keys: {@a, 0, @d, @f, @g, @h}},
      %{keys: {@a, 0, @d, 0, @g, @h}},
      %{keys: {@a, 0, @d, 0, @g, 0}},
      # releasing and pressing k007 again allows it to take one of the freed
      # spots
      %{keys: {@a, @j, @d, 0, @g, 0}}
    ]
  end
end
