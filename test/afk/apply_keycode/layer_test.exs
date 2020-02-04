defmodule AFK.ApplyKeycode.LayerTest do
  @moduledoc false

  use AFK.SixKeyCase, async: true

  alias AFK.Keycode.{Key, Layer, None, Transparent}
  alias AFK.State

  @q Key.new(:q)
  @w Key.new(:w)
  @e Key.new(:e)

  @a Key.new(:a)
  @s Key.new(:s)

  @z Key.new(:z)

  @one Key.new(:"1")

  @none None.new()
  @transparent Transparent.new()

  @hold_for_layer_1 Layer.new(:hold, 1)
  @hold_for_layer_2 Layer.new(:hold, 2)
  @toggle_layer_1 Layer.new(:toggle, 1)
  @default_to_layer_3 Layer.new(:default, 3)
  @default_to_layer_0 Layer.new(:default, 0)

  @layer_0 %{
    k001: @hold_for_layer_1,
    k002: @none,
    k003: @none,
    k004: @q,
    k005: @w,
    k006: @e,
    k007: @toggle_layer_1,
    k008: @default_to_layer_3
  }

  @layer_1 %{
    k001: @none,
    k002: @hold_for_layer_2,
    k003: @none,
    k004: @a,
    k005: @s,
    k006: @transparent,
    k007: @transparent,
    k008: @transparent
  }

  @layer_2 %{
    k001: @none,
    k002: @none,
    k003: @hold_for_layer_1,
    k004: @z,
    k005: @transparent,
    k006: @transparent,
    k007: @transparent,
    k008: @transparent
  }

  @layer_3 %{
    k001: @one,
    k002: @none,
    k003: @none,
    k004: @none,
    k005: @none,
    k006: @none,
    k007: @none,
    k008: @default_to_layer_0
  }

  @keymap [
    @layer_0,
    @layer_1,
    @layer_2,
    @layer_3
  ]

  @moduletag keymap: @keymap

  test "the first layer is considered default and always active", %{state: state} do
    State.press_key(state, :k004)

    assert_hid_reports([
      %{keys: {@q, 0, 0, 0, 0, 0}}
    ])
  end

  describe "while holding layer 1 activation key" do
    setup %{state: state} do
      State.press_key(state, :k001)

      :ok
    end

    test "press a regular key", %{state: state} do
      State.press_key(state, :k004)

      assert_hid_reports([
        %{keys: {@a, 0, 0, 0, 0, 0}}
      ])
    end

    test "press a none key", %{state: state} do
      State.press_key(state, :k003)

      # has no effect (does not fall through to lower level)
      assert_hid_reports([])
    end

    test "press a transparent key", %{state: state} do
      State.press_key(state, :k006)

      # falls through to lower active layer (0)
      assert_hid_reports([
        %{keys: {@e, 0, 0, 0, 0, 0}}
      ])
    end

    test "let go of layer 1 activation key", %{state: state} do
      State.release_key(state, :k001)
      State.press_key(state, :k004)

      # layer 1 no longer active, so this is layer 0 (default)
      assert_hid_reports([
        %{keys: {@q, 0, 0, 0, 0, 0}}
      ])
    end
  end

  describe "while holding layer 1 and layer 2 activation keys" do
    setup %{state: state} do
      State.press_key(state, :k001)
      State.press_key(state, :k002)

      :ok
    end

    test "press a regular key", %{state: state} do
      State.press_key(state, :k004)

      assert_hid_reports([
        %{keys: {@z, 0, 0, 0, 0, 0}}
      ])
    end

    test "press a transparent key that falls to layer 1 (still active)", %{state: state} do
      State.press_key(state, :k005)

      # falls through to lower active layer (1)
      assert_hid_reports([
        %{keys: {@s, 0, 0, 0, 0, 0}}
      ])
    end

    test "press a transparent key that falls to layer 0 (default)", %{state: state} do
      State.press_key(state, :k006)

      # falls through two layers to default layer (0)
      assert_hid_reports([
        %{keys: {@e, 0, 0, 0, 0, 0}}
      ])
    end

    test "let go of layer 1 activation key and press a transparent key that falls to layer 1", %{
      state: state
    } do
      State.release_key(state, :k001)
      State.press_key(state, :k005)

      # layer 1 is no longer active, so it skips layer 1 and uses 0
      assert_hid_reports([
        %{keys: {@w, 0, 0, 0, 0, 0}}
      ])
    end

    test "activating layer 1 a second time", %{state: state} do
      State.press_key(state, :k003)

      # layer 1 is considered active
      State.press_key(state, :k005)
      State.release_key(state, :k005)

      # releasing the first activation key by itself still keeps layer 1 active
      State.release_key(state, :k001)
      State.press_key(state, :k005)
      State.release_key(state, :k005)

      # only releasing both activation keys will deactivate layer 1
      State.release_key(state, :k003)
      State.press_key(state, :k005)
      State.release_key(state, :k005)

      assert_hid_reports([
        %{keys: {@s, 0, 0, 0, 0, 0}},
        %{keys: {0, 0, 0, 0, 0, 0}},
        %{keys: {@s, 0, 0, 0, 0, 0}},
        %{keys: {0, 0, 0, 0, 0, 0}},
        %{keys: {@w, 0, 0, 0, 0, 0}},
        %{keys: {0, 0, 0, 0, 0, 0}}
      ])
    end
  end

  describe "after toggling layer 1" do
    setup %{state: state} do
      State.press_key(state, :k007)
      State.release_key(state, :k007)

      :ok
    end

    test "layer 1 is active", %{state: state} do
      State.press_key(state, :k004)

      assert_hid_reports([
        %{keys: {@a, 0, 0, 0, 0, 0}}
      ])
    end

    test "toggling layer 1 again deactivates", %{state: state} do
      State.press_key(state, :k007)
      State.release_key(state, :k007)
      State.press_key(state, :k004)

      assert_hid_reports([
        %{keys: {@q, 0, 0, 0, 0, 0}}
      ])
    end
  end

  describe "switch default layers" do
    test "switch to layer 3 as the default layer", %{state: state} do
      State.press_key(state, :k008)
      State.release_key(state, :k008)
      State.press_key(state, :k001)

      assert_hid_reports([
        %{keys: {@one, 0, 0, 0, 0, 0}}
      ])
    end

    test "switches the default layer as soon as it's pressed", %{state: state} do
      State.press_key(state, :k008)
      State.press_key(state, :k001)

      assert_hid_reports([
        %{keys: {@one, 0, 0, 0, 0, 0}}
      ])
    end

    test "switch to layer 3 as the default layer then back to 1", %{state: state} do
      State.press_key(state, :k008)
      State.release_key(state, :k008)
      State.press_key(state, :k001)
      State.press_key(state, :k008)
      State.release_key(state, :k008)
      State.press_key(state, :k004)

      assert_hid_reports([
        %{keys: {@one, 0, 0, 0, 0, 0}},
        %{keys: {@one, @q, 0, 0, 0, 0}}
      ])
    end
  end
end
