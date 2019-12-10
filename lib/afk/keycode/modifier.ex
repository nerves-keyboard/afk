defmodule AFK.Keycode.Modifier do
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
      %AFK.Keycode.Modifier{modifier: :left_control}

      iex> new(:right_super)
      %AFK.Keycode.Modifier{modifier: :right_super}
  """
  for {_value, modifier} <- AFK.Scancode.modifiers() do
    def new(unquote(modifier)), do: struct!(__MODULE__, modifier: unquote(modifier))
  end

  defimpl AFK.Scancode.Protocol do
    for {value, modifier} <- AFK.Scancode.modifiers() do
      def scancode(%AFK.Keycode.Modifier{modifier: unquote(modifier)}), do: unquote(value)
    end
  end

  defimpl AFK.ApplyKeycode, for: AFK.Keycode.Modifier do
    def apply_keycode(keycode, state, key) do
      modifier_used? =
        Enum.any?(state.modifiers, fn
          {_key, ^keycode} -> true
          _ -> false
        end)

      if modifier_used? do
        state
      else
        modifiers = Map.put(state.modifiers, key, keycode)

        %{state | modifiers: modifiers}
      end
    end

    def unapply_keycode(keycode, state, key) do
      modifiers =
        state.modifiers
        |> Enum.filter(fn
          {^key, ^keycode} -> false
          _ -> true
        end)
        |> Map.new()

      %{state | modifiers: modifiers}
    end
  end
end
