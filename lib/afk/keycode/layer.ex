defmodule AFK.Keycode.Layer do
  @moduledoc """
  Represents a key that can activate other layers on and off in various ways.

  Layers can be activated in 3 ways:

  * `:hold` - Temporarily activates a layer while being held
  * `:toggle` - Toggles a layer on or off when pressed
  * `:default` - Sets a layer as the default layer
  """

  @enforce_keys [:type, :layer]
  defstruct [:type, :layer]

  @doc """
  Creates a layer activation keycode.

  The valid types are:

  * `:hold` - Activates a layer while being held
  * `:toggle` - Toggles a layer on or off when pressed
  * `:default` - Sets a layer as the default layer

  ## Examples

      iex> new(:hold, 1)
      %AFK.Keycode.Layer{layer: 1, type: :hold}

      iex> new(:hold, 2)
      %AFK.Keycode.Layer{layer: 2, type: :hold}

      iex> new(:toggle, 1)
      %AFK.Keycode.Layer{layer: 1, type: :toggle}

      iex> new(:default, 2)
      %AFK.Keycode.Layer{layer: 2, type: :default}
  """
  def new(type, layer) when type in ~w(hold toggle default)a and is_integer(layer) and layer >= 0 do
    struct!(__MODULE__,
      type: type,
      layer: layer
    )
  end

  defimpl AFK.ApplyKeycode do
    alias AFK.Keycode.Layer
    alias AFK.State.Keymap

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
end
