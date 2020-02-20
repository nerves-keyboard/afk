defmodule AFK.Keycode do
  @moduledoc """
  A keycode represents a key that when pressed affects the keyboard state in
  some way.

  The currently supported keycode types are:

  * `AFK.Keycode.Key` - A basic keyboard key
  * `AFK.Keycode.KeyLock` - A key that allows locking other keys
  * `AFK.Keycode.Layer` - A key that can activate other layers
  * `AFK.Keycode.Modifier` - A basic keyboard modifier
  * `AFK.Keycode.None` - A keycode that does nothing
  * `AFK.Keycode.Transparent` - A key that is transparent to its layer
  """

  alias __MODULE__.{Key, KeyLock, Layer, MFA, Modifier, None, Transparent}

  @type t :: Key.t() | KeyLock.t() | Layer.t() | MFA.t() | Modifier.t() | None.t() | Transparent.t()

  @type with_scancode :: Key.t() | Modifier.t()
end
