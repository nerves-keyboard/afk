defmodule AFK.State.ApplyKeycode.KeyTest do
  use AFK.KeycodeCase

  alias AFK.State
  alias AFK.Keycodes.Key

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

  test "raises if same physical key is pressed twice" do
    state = @keymap |> State.new() |> State.press_key(:k001)

    assert_raise RuntimeError, fn ->
      State.press_key(state, :k001)
    end
  end

  test "raises if same physical key is release twice" do
    state =
      @keymap
      |> State.new()
      |> State.press_key(:k001)
      |> State.release_key(:k001)

    assert_raise RuntimeError, fn ->
      State.release_key(state, :k001)
    end
  end

  test "press and release a" do
    state = @keymap |> State.new() |> State.press_key(:k001)
    assert_6kr(state, [@a, 0, 0, 0, 0, 0])

    state = State.release_key(state, :k001)
    assert_6kr(state, [0, 0, 0, 0, 0, 0])
  end

  test "activating the same keycode using two different physical keys" do
    state =
      @keymap
      |> State.new()
      |> State.press_key(:k001)
      |> State.press_key(:k010)

    # a is only pressed once
    assert_6kr(state, [@a, 0, 0, 0, 0, 0])

    # releasing the second instance of a doesn't release a
    state = State.release_key(state, :k010)
    assert_6kr(state, [@a, 0, 0, 0, 0, 0])

    # releasing the original instance of a releases it
    state = State.release_key(state, :k001)
    assert_6kr(state, [0, 0, 0, 0, 0, 0])
  end

  test "pressing more than 6 keys causes later presses to be ignored" do
    state =
      Enum.reduce(
        ~w(k001 k002 k003 k004 k005 k006 k007 k008 k009)a,
        State.new(@keymap),
        &State.press_key(&2, &1)
      )

    # the 6-key HID buffer is full and cannot express that j, k, and l are also
    # all pressed
    assert_6kr(state, [@a, @s, @d, @f, @g, @h])
  end

  test "HID buffer ordering" do
    state =
      Enum.reduce(
        ~w(k001 k002 k003 k004 k005 k006 k007 k008 k009)a,
        State.new(@keymap),
        &State.press_key(&2, &1)
      )

    state =
      Enum.reduce(
        ~w(k002 k004 k006)a,
        state,
        &State.release_key(&2, &1)
      )

    # the released keys free up new spots, but the other held keys do not fill
    # them
    assert_6kr(state, [@a, 0, @d, 0, @g, 0])

    # releasing and pressing again allows it to take one of the freed spots
    state =
      state
      |> State.release_key(:k007)
      |> State.press_key(:k007)

    assert_6kr(state, [@a, @j, @d, 0, @g, 0])
  end
end
