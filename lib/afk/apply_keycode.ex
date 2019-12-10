defprotocol AFK.ApplyKeycode do
  @moduledoc false

  def apply_keycode(keycode, state, key)
  def unapply_keycode(keycode, state, key)
end
