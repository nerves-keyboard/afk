defprotocol AFK.State.ApplyKeycode do
  @moduledoc """
  Applies a keycode to a keyboard state struct.
  """

  @doc "Applies a keycode to the keyboard state"
  def apply_keycode(keycode, state, key)

  @doc "Unapplies a keycode from the keyboard state"
  def unapply_keycode(keycode, state, key)
end
