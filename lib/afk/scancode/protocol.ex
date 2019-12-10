defprotocol AFK.Scancode.Protocol do
  @moduledoc false

  @spec scancode(AFK.Keycode.with_scancode()) :: AFK.Scancode.t()
  def scancode(keycode)
end
