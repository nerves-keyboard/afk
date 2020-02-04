defmodule AFK.HIDReport.SixKeyRollover do
  @moduledoc """
  Implements the `AFK.HIDReport` behaviour to produce a standard 6-key rollover
  USB keyboard HID report.

  The report is an 8-byte binary with the first byte being a bitmap of modifier
  keys that are currently active, the second byte being zero (reserved), and the
  following 6 bytes are the first 6 key scancodes that are active. Any
  additionally active keys are ignored in this report.
  """

  @behaviour AFK.HIDReport

  use Bitwise

  import AFK.Scancode, only: [scancode: 1]

  @impl AFK.HIDReport
  @spec hid_report(state :: AFK.State.t()) :: <<_::64>>
  def hid_report(%AFK.State{} = state) do
    modifiers_byte =
      Enum.reduce(state.modifiers, 0, fn {_key, keycode}, acc ->
        scancode(keycode) ||| acc
      end)

    [one, two, three, four, five, six] =
      Enum.map(0..5, fn i ->
        case state.indexed_keys[i] do
          nil -> 0
          {_key, %AFK.Keycode.Key{} = keycode} -> scancode(keycode)
        end
      end)

    <<modifiers_byte, 0, one, two, three, four, five, six>>
  end
end
