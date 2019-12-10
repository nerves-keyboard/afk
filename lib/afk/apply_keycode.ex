defprotocol AFK.ApplyKeycode do
  @moduledoc false

  @spec apply_keycode(AFK.Keycode.t(), AFK.State.t(), term) :: AFK.State.t()
  def apply_keycode(keycode, state, key)

  @spec unapply_keycode(AFK.Keycode.t(), AFK.State.t(), term) :: AFK.State.t()
  def unapply_keycode(keycode, state, key)
end
