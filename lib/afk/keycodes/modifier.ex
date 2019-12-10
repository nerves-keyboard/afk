defmodule AFK.Keycodes.Modifier do
  @moduledoc """
  Represents a basic modifier keycode, like control, shift, etc.

  All standard modifiers on a keyboard can be represented by `Modifier`
  keycodes. The following is a list of all supported modifiers:

  * `:left_control`
  * `:left_shift`
  * `:left_alt`
  * `:left_super`
  * `:right_control`
  * `:right_shift`
  * `:right_alt`
  * `:right_super`
  """

  @enforce_keys [:modifier]
  defstruct [:modifier]

  @doc """
  Creates a basic modifier keycode.

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
