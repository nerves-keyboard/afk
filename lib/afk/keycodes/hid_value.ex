defprotocol AFK.Keycodes.HIDValue do
  @moduledoc """
  Returns the HID value for keycodes.

  Implemented by `AFK.Keycodes.Key` and `AFK.Keycodes.Modifier` only.
  """

  @doc "Returns the HID value for the given keycode"
  def hid_value(keycode)
end
