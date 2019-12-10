defmodule AFK.Keycode do
  @moduledoc """
  A keycode represents a key that when pressed affects the keyboard state in
  some way.

  The currently supported keycode types are:

  * `AFK.Keycode.Key` - A basic keyboard key
  * `AFK.Keycode.Layer` - A key that can activate other layers
  * `AFK.Keycode.Modifier` - A basic keyboard modifier
  * `AFK.Keycode.None` - A keycode that does nothing
  * `AFK.Keycode.Transparent` - A key that is transparent to its layer
  """
end
