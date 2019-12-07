defimpl Keyboard.State.ApplyKeycode, for: Keyboard.Keycodes.None do
  def apply_keycode(_keycode, state, _key) do
    state
  end

  def unapply_keycode(_keycode, state, _key) do
    state
  end
end
