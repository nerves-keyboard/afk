defimpl Keyboard.State.ApplyKeycode, for: Keyboard.Keycodes.Layer do
  alias Keyboard.Keycodes.Layer
  alias Keyboard.State.Keymap

  def apply_keycode(%Layer{type: :hold} = keycode, state, key) do
    keymap = Keymap.add_activation(state.keymap, keycode, key)

    %{state | keymap: keymap}
  end

  def apply_keycode(%Layer{type: :toggle} = keycode, state, key) do
    keymap = Keymap.toggle_activation(state.keymap, keycode, key)

    %{state | keymap: keymap}
  end

  def apply_keycode(%Layer{type: :default} = keycode, state, key) do
    keymap = Keymap.set_default(state.keymap, keycode, key)

    %{state | keymap: keymap}
  end

  def unapply_keycode(%Layer{type: :hold} = keycode, state, key) do
    keymap = Keymap.remove_activation(state.keymap, keycode, key)

    %{state | keymap: keymap}
  end

  def unapply_keycode(%Layer{type: :toggle}, state, _key) do
    state
  end

  def unapply_keycode(%Layer{type: :default}, state, _key) do
    state
  end
end
