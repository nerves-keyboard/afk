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
    @spec scancode(AFK.Keycode.Key.t()) :: AFK.Scancode.t()
    def scancode(keycode)

    for {value, key} <- AFK.Scancode.keys() do
      def scancode(%AFK.Keycode.Key{key: unquote(key)}), do: unquote(value)
    end
  end

  defimpl AFK.ApplyKeycode do
    @spec apply_keycode(AFK.Keycode.Key.t(), AFK.State.t(), atom) :: AFK.State.t()
    def apply_keycode(keycode, state, key) do
      keycode_used? =
        Enum.any?(state.indexed_keys, fn
          {_index, {_key, ^keycode}} -> true
          _else -> false
        end)

      if keycode_used? do
        state
      else
        lowest_available_index =
          Enum.reduce_while(Stream.iterate(0, &(&1 + 1)), state.indexed_keys, fn index, acc ->
            case acc[index] do
              nil -> {:halt, index}
              _else -> {:cont, acc}
            end
          end)

        indexed_keys = Map.put(state.indexed_keys, lowest_available_index, {key, keycode})

        %{state | indexed_keys: indexed_keys}
      end
    end

    @spec unapply_keycode(AFK.Keycode.Key.t(), AFK.State.t(), atom) :: AFK.State.t()
    def unapply_keycode(keycode, state, key) do
      index =
        Enum.find_value(state.indexed_keys, fn
          {index, {^key, ^keycode}} -> index
          _else -> nil
        end)

      indexed_keys = Map.delete(state.indexed_keys, index)

      %{state | indexed_keys: indexed_keys}
    end
  end
end
