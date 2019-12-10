defmodule AFK.Keycode.Key do
  @moduledoc """
  Represents a basic keyboard keycode, like letters, numbers, etc.

  All standard keys on a keyboard except the modifiers can be represented by
  `Key` keycodes. The currently supported keys are `t:key/0`.
  """

  @enforce_keys [:key]
  defstruct [:key]

  @type key ::
          unquote(
            AFK.Scancode.keys()
            |> Enum.map(&elem(&1, 1))
            |> Enum.reverse()
            |> Enum.reduce(&{:|, [], [&1, &2]})
          )

  @type t :: %__MODULE__{
          key: key
        }

  @doc """
  Creates a basic key keycode.

  ## Examples

      iex> new(:a)
      %AFK.Keycode.Key{key: :a}

      iex> new(:up)
      %AFK.Keycode.Key{key: :up}
  """
  @spec new(key) :: t
  def new(key)

  for {_value, key} <- AFK.Scancode.keys() do
    def new(unquote(key)), do: struct!(__MODULE__, key: unquote(key))
  end

  defimpl AFK.Scancode.Protocol do
    for {value, key} <- AFK.Scancode.keys() do
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
