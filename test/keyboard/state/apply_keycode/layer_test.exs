defmodule Keyboard.State.ApplyKeycode.LayerTest do
  use Keyboard.KeycodeCase

  alias Keyboard.State
  alias Keyboard.Keycodes.{Key, Layer, None, Transparent}

  @q Key.from_id!(:q)
  @w Key.from_id!(:w)
  @e Key.from_id!(:e)
  @r Key.from_id!(:r)

  @a Key.from_id!(:a)
  @s Key.from_id!(:s)
  @d Key.from_id!(:d)

  @z Key.from_id!(:z)
  @x Key.from_id!(:x)

  @none %None{}
  @transparent %Transparent{}

  @hold_for_layer_1 Layer.new(:hold, 1)
  @hold_for_layer_2 Layer.new(:hold, 2)

  @layer_0 %{
    k001: @hold_for_layer_1,
    k002: @none,
    k003: @none,
    k004: @q,
    k005: @w,
    k006: @e,
    k007: @r
  }

  @layer_1 %{
    k001: @none,
    k002: @hold_for_layer_2,
    k003: @none,
    k004: @a,
    k005: @s,
    k006: @d,
    k007: @transparent
  }

  @layer_2 %{
    k001: @none,
    k002: @none,
    k003: @hold_for_layer_1,
    k004: @z,
    k005: @x,
    k006: @transparent,
    k007: @transparent
  }

  @layer_3 %{
    k001: @none,
    k002: @none,
    k003: @none,
    k004: @none,
    k005: @none,
    k006: @none,
    k007: @none
  }

  @keymap [
    @layer_0,
    @layer_1,
    @layer_2,
    @layer_3
  ]

  test "the first layer is considered default and always active" do
    state = @keymap |> State.new() |> State.press_key(:k004)

    assert_6kr(state, [@q, 0, 0, 0, 0, 0])
  end

  describe "while holding layer 1 activation key" do
    setup do
      state =
        @keymap
        |> State.new()
        |> State.press_key(:k001)

      {:ok, [state: state]}
    end

    test "press a regular key", %{state: state} do
      state = State.press_key(state, :k004)

      assert_6kr(state, [@a, 0, 0, 0, 0, 0])
    end

    test "press a none key", %{state: state} do
      state = State.press_key(state, :k003)

      # has no effect (does not fall through to lower level)
      assert_6kr(state, [0, 0, 0, 0, 0, 0])
    end

    test "press a transparent key", %{state: state} do
      state = State.press_key(state, :k007)

      # falls through to lower active layer (0)
      assert_6kr(state, [@r, 0, 0, 0, 0, 0])
    end

    test "let go of layer 1 activation key", %{state: state} do
      state =
        state
        |> State.release_key(:k001)
        |> State.press_key(:k004)

      # layer 1 no longer active, so this is layer 0 (default)
      assert_6kr(state, [@q, 0, 0, 0, 0, 0])
    end
  end

  describe "while holding layer 1 and layer 2 activation keys" do
    setup do
      state =
        @keymap
        |> State.new()
        |> State.press_key(:k001)
        |> State.press_key(:k002)

      {:ok, [state: state]}
    end

    test "press a regular key", %{state: state} do
      state = State.press_key(state, :k004)

      assert_6kr(state, [@z, 0, 0, 0, 0, 0])
    end

    test "press a transparent key that falls to layer 1 (still active)", %{state: state} do
      state = State.press_key(state, :k006)

      # falls through to lower active layer (1)
      assert_6kr(state, [@d, 0, 0, 0, 0, 0])
    end

    test "press a transparent key that falls to layer 0 (default)", %{state: state} do
      state = State.press_key(state, :k007)

      # falls through two layers to default layer (0)
      assert_6kr(state, [@r, 0, 0, 0, 0, 0])
    end

    test "let go of layer 1 activation key and press a transparent key that falls to layer 1", %{
      state: state
    } do
      state =
        state
        |> State.release_key(:k001)
        |> State.press_key(:k006)

      # layer 1 is no longer active, so it skips layer 1 and uses 0
      assert_6kr(state, [@e, 0, 0, 0, 0, 0])
    end

    test "activating layer 1 a second time", %{state: state} do
      state = State.press_key(state, :k003)

      # layer 1 is considered active
      state
      |> State.press_key(:k006)
      |> assert_6kr([@d, 0, 0, 0, 0, 0])

      # releasing the first activation key still keeps layer 1 active
      state
      |> State.release_key(:k001)
      |> State.press_key(:k006)
      |> assert_6kr([@d, 0, 0, 0, 0, 0])

      # releasing the second activation key still keeps layer 1 active
      state
      |> State.release_key(:k003)
      |> State.press_key(:k006)
      |> assert_6kr([@d, 0, 0, 0, 0, 0])

      # only releasing both activation keys will deactivate layer 1
      state
      |> State.release_key(:k001)
      |> State.release_key(:k003)
      |> State.press_key(:k006)
      |> assert_6kr([@e, 0, 0, 0, 0, 0])
    end
  end
end
