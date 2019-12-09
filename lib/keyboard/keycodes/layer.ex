defmodule AFK.Keycodes.Layer do
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
      %AFK.Keycodes.Layer{layer: 1, type: :hold}

      iex> new(:hold, 2)
      %AFK.Keycodes.Layer{layer: 2, type: :hold}

      iex> new(:toggle, 1)
      %AFK.Keycodes.Layer{layer: 1, type: :toggle}

      iex> new(:default, 2)
      %AFK.Keycodes.Layer{layer: 2, type: :default}
  """
  def new(type, layer) when type in ~w(hold toggle default)a do
    struct!(__MODULE__,
      type: type,
      layer: layer
    )
  end
end
