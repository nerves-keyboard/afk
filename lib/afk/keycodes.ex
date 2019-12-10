defmodule AFK.Keycodes do
  @moduledoc """
  A keycode represents a key that when pressed affects the keyboard state in
  some way.

  The currently supported keycode types are:

  * `AFK.Keycodes.Key` - A basic keyboard key
  * `AFK.Keycodes.Layer` - A key that can activate other layers
  * `AFK.Keycodes.Modifier` - A basic keyboard modifier
  * `AFK.Keycodes.None` - A keycode that does nothing
  * `AFK.Keycodes.Transparent` - A key that is transparent to its layer
  """
end
