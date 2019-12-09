defmodule AFK.Keycodes.Key do
  @moduledoc """
  TODO
  """

  @enforce_keys [:key]
  defstruct [:key]

  @doc """
  Creates a basic key keycode struct.

  ## Examples

      iex> new(:a)
      %AFK.Keycodes.Key{key: :a}

      iex> new(:up)
      %AFK.Keycodes.Key{key: :up}
  """
  for {_value, key} <- AFK.Scancodes.keyboard() do
    def new(unquote(key)), do: struct!(__MODULE__, key: unquote(key))
  end

  defimpl AFK.Keycodes.HIDValue do
    for {value, key} <- AFK.Scancodes.keyboard() do
      def hid_value(%AFK.Keycodes.Key{key: unquote(key)}), do: unquote(value)
    end
  end
end
