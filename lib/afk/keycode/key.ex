defmodule AFK.Keycode.Key do
  @moduledoc """
  Represents a basic keyboard keycode, like letters, numbers, etc.

  All standard keys on a keyboard except the modifiers can be represented by
  `Key` keycodes. The following is a list of currently supported keys:

  * `:a`
  * `:b`
  * `:c`
  * `:d`
  * `:e`
  * `:f`
  * `:g`
  * `:h`
  * `:i`
  * `:j`
  * `:k`
  * `:l`
  * `:m`
  * `:n`
  * `:o`
  * `:p`
  * `:q`
  * `:r`
  * `:s`
  * `:t`
  * `:u`
  * `:v`
  * `:w`
  * `:x`
  * `:y`
  * `:z`
  * `:"1"`
  * `:"2"`
  * `:"3"`
  * `:"4"`
  * `:"5"`
  * `:"6"`
  * `:"7"`
  * `:"8"`
  * `:"9"`
  * `:"0"`
  * `:enter`
  * `:escape`
  * `:backspace`
  * `:tab`
  * `:space`
  * `:minus`
  * `:equals`
  * `:left_square_bracket`
  * `:right_square_bracket`
  * `:backslash`
  * `:semicolon`
  * `:single_quote`
  * `:grave`
  * `:comma`
  * `:period`
  * `:slash`
  * `:caps_lock`
  * `:f1`
  * `:f2`
  * `:f3`
  * `:f4`
  * `:f5`
  * `:f6`
  * `:f7`
  * `:f8`
  * `:f9`
  * `:f10`
  * `:f11`
  * `:f12`
  * `:print_screen`
  * `:scroll_lock`
  * `:pause`
  * `:insert`
  * `:home`
  * `:page_up`
  * `:delete`
  * `:end`
  * `:page_down`
  * `:right`
  * `:left`
  * `:down`
  * `:up`
  * `:application`
  """

  @enforce_keys [:key]
  defstruct [:key]

  @doc """
  Creates a basic key keycode.

  ## Examples

      iex> new(:a)
      %AFK.Keycode.Key{key: :a}

      iex> new(:up)
      %AFK.Keycode.Key{key: :up}
  """
  for {_value, key} <- AFK.Scancode.keyboard() do
    def new(unquote(key)), do: struct!(__MODULE__, key: unquote(key))
  end

  defimpl AFK.Scancode.Protocol do
    for {value, key} <- AFK.Scancode.keyboard() do
      def scancode(%AFK.Keycode.Key{key: unquote(key)}), do: unquote(value)
    end
  end

  defimpl AFK.ApplyKeycode do
    def apply_keycode(keycode, state, key) do
      keycode_used? =
        Enum.any?(state.six_keys, fn
          nil -> false
          {_, kc} -> kc == keycode
        end)

      if keycode_used? do
        state
      else
        {six_keys, _} =
          Enum.map_reduce(state.six_keys, keycode, fn
            x, nil -> {x, nil}
            nil, kc -> {{key, kc}, nil}
            x, kc -> {x, kc}
          end)

        %{state | six_keys: six_keys}
      end
    end

    def unapply_keycode(keycode, state, key) do
      six_keys =
        Enum.map(state.six_keys, fn
          {^key, ^keycode} -> nil
          x -> x
        end)

      %{state | six_keys: six_keys}
    end
  end
end
