defmodule Keyboard.Keycodes.Layer do
  @enforce_keys [:type, :layer]
  defstruct [:type, :layer]

  @doc """
  Creates a layer activation keycode.

  The only type currently supported is `:hold`, which allows activation of
  another layer by holding the key.

  ## Examples

      iex> new(:hold, 1)
      %Keyboard.Keycodes.Layer{layer: 1, type: :hold}

      iex> new(:hold, 2)
      %Keyboard.Keycodes.Layer{layer: 2, type: :hold}
  """
  def new(:hold = type, layer) do
    struct!(__MODULE__,
      type: type,
      layer: layer
    )
  end
end
