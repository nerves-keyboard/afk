defmodule AFK.Keycodes.Modifier do
  @moduledoc """
  TODO
  """

  @enforce_keys [:modifier]
  defstruct [:modifier]

  @doc """
  Creates a basic modifier keycode struct.

  ## Examples

      iex> new(:left_control)
      %AFK.Keycodes.Modifier{modifier: :left_control}

      iex> new(:right_super)
      %AFK.Keycodes.Modifier{modifier: :right_super}
  """
  for {_value, modifier} <- AFK.Scancodes.modifiers() do
    def new(unquote(modifier)), do: struct!(__MODULE__, modifier: unquote(modifier))
  end

  defimpl AFK.Keycodes.HIDValue do
    for {value, modifier} <- AFK.Scancodes.modifiers() do
      def hid_value(%AFK.Keycodes.Modifier{modifier: unquote(modifier)}), do: unquote(value)
    end
  end
end
