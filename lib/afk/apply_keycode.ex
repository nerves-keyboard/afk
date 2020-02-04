defprotocol AFK.ApplyKeycode do
  @moduledoc false

  @spec apply_keycode(keycode :: AFK.Keycode.t(), state :: AFK.State.t(), key :: atom) :: AFK.State.t()
  def apply_keycode(keycode, state, key)

  @spec unapply_keycode(keycode :: AFK.Keycode.t(), state :: AFK.State.t(), key :: atom) :: AFK.State.t()
  def unapply_keycode(keycode, state, key)
end
