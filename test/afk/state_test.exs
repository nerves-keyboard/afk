defmodule AFK.StateTest do
  @moduledoc false

  use AFK.SixKeyCase, async: true

  alias AFK.HIDReport.SixKeyRollover
  alias AFK.State

  @moduletag keymap: []

  test "raises if trying to start without providing :event_receiver" do
    assert_raise KeyError, ~r/key :event_receiver not found/, fn ->
      State.start_link(
        keymap: [],
        hid_report_mod: SixKeyRollover
      )
    end
  end

  test "raises if trying to start without providing :keymap" do
    assert_raise KeyError, ~r/key :keymap not found/, fn ->
      State.start_link(
        event_receiver: self(),
        hid_report_mod: SixKeyRollover
      )
    end
  end

  test "raises if trying to start without providing :hid_report_mod" do
    assert_raise KeyError, ~r/key :hid_report_mod not found/, fn ->
      State.start_link(
        event_receiver: self(),
        keymap: []
      )
    end
  end

  @tag :capture_log
  test "exits if same physical key is pressed twice", %{state: state} do
    Process.flag(:trap_exit, true)

    State.press_key(state, :k001)
    State.press_key(state, :k001)

    assert_receive {:EXIT, ^state,
                    {%RuntimeError{
                       message: "Already pressed key pressed again! k001"
                     }, _}}
  end

  @tag :capture_log
  test "exits if same physical key is released twice", %{state: state} do
    Process.flag(:trap_exit, true)

    State.press_key(state, :k001)
    State.release_key(state, :k001)
    State.release_key(state, :k001)

    assert_receive {:EXIT, ^state,
                    {%RuntimeError{
                       message: "Unpressed key released! k001"
                     }, _}}
  end
end
