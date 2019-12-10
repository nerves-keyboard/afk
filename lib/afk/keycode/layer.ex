defmodule AFK.Keycode.Layer do
  @moduledoc """
  Represents a key that can activate other layers on and off in various ways.

  Layers can be activated in 3 ways:

  * `:hold` - Temporarily activates a layer while being held
  * `:toggle` - Toggles a layer on or off when pressed
  * `:default` - Sets a layer as the default layer
  """

  @enforce_keys [:mode, :layer]
  defstruct [:mode, :layer]

  @type mode :: :default | :hold | :toggle
  @type layer :: non_neg_integer

  @type t :: %__MODULE__{
          mode: mode,
          layer: layer
        }

  @doc """
  Creates a layer activation keycode.

  The valid types are:

  * `:hold` - Activates a layer while being held
  * `:toggle` - Toggles a layer on or off when pressed
  * `:default` - Sets a layer as the default layer

  ## Examples

      iex> new(:hold, 1)
      %AFK.Keycode.Layer{layer: 1, mode: :hold}

      iex> new(:hold, 2)
      %AFK.Keycode.Layer{layer: 2, mode: :hold}

      iex> new(:toggle, 1)
      %AFK.Keycode.Layer{layer: 1, mode: :toggle}

      iex> new(:default, 2)
      %AFK.Keycode.Layer{layer: 2, mode: :default}
  """
  @spec new(mode, layer) :: t
  def new(mode, layer) do
    struct!(__MODULE__,
      mode: mode,
      layer: layer
    )
  end

  defimpl AFK.ApplyKeycode do
    alias AFK.Keycode.Layer
    alias AFK.State.Keymap

    def apply_keycode(%Layer{mode: :hold} = keycode, state, key) do
      keymap = Keymap.add_activation(state.keymap, keycode, key)

      %{state | keymap: keymap}
    end

    def apply_keycode(%Layer{mode: :toggle} = keycode, state, key) do
      keymap = Keymap.toggle_activation(state.keymap, keycode, key)

      %{state | keymap: keymap}
    end

    def apply_keycode(%Layer{mode: :default} = keycode, state, key) do
      keymap = Keymap.set_default(state.keymap, keycode, key)

      %{state | keymap: keymap}
    end

    def unapply_keycode(%Layer{mode: :hold} = keycode, state, key) do
      keymap = Keymap.remove_activation(state.keymap, keycode, key)

      %{state | keymap: keymap}
    end

    def unapply_keycode(%Layer{mode: :toggle}, state, _key) do
      state
    end

    def unapply_keycode(%Layer{mode: :default}, state, _key) do
      state
    end
  end
end
