defmodule AFK.StateTest do
  use AFK.SixKeyCase, async: true

  alias AFK.State

  @moduletag keymap: []

  # TODO: add some more tests around starting the process successfully and
  # unsuccessfully.

  @tag :capture_log
  test "exits if same physical key is pressed twice", %{state: state} do
    Process.flag(:trap_exit, true)

    State.press_key(state, :k001)
    State.press_key(state, :k001)

    assert_receive(
      {:EXIT, ^state,
       {%RuntimeError{
          message: "Already pressed key pressed again! k001"
        }, _}}
    )
  end

  @tag :capture_log
  test "exits if same physical key is released twice", %{state: state} do
    Process.flag(:trap_exit, true)

    State.press_key(state, :k001)
    State.release_key(state, :k001)
    State.release_key(state, :k001)

    assert_receive(
      {:EXIT, ^state,
       {%RuntimeError{
          message: "Unpressed key released! k001"
        }, _}}
    )
  end
end
