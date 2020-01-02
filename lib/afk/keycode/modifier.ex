defmodule AFK.Keycode.Modifier do
  @moduledoc """
  Represents a basic modifier keycode, like control, shift, etc.

  All standard modifiers on a keyboard can be represented by `Modifier`
  keycodes. The currently supported modifiers are `t:modifier/0`.
  """

  @enforce_keys [:modifier]
  defstruct [:modifier]

  @type modifier ::
          unquote(
            AFK.Scancode.modifiers()
            |> Enum.map(&elem(&1, 1))
            |> Enum.reverse()
            |> Enum.reduce(&{:|, [], [&1, &2]})
          )

  @type t :: %__MODULE__{
          modifier: modifier
        }

  @doc """
  Creates a basic modifier keycode.

  ## Examples

      iex> new(:left_control)
      %AFK.Keycode.Modifier{modifier: :left_control}

      iex> new(:right_super)
      %AFK.Keycode.Modifier{modifier: :right_super}
  """
  @spec new(modifier) :: t
  def new(modifier)

  for {_value, modifier} <- AFK.Scancode.modifiers() do
    def new(unquote(modifier)), do: struct!(__MODULE__, modifier: unquote(modifier))
  end

  defimpl AFK.Scancode.Protocol do
    @spec scancode(AFK.Keycode.Modifier.t()) :: AFK.Scancode.t()
    def scancode(keycode)

    for {value, modifier} <- AFK.Scancode.modifiers() do
      def scancode(%AFK.Keycode.Modifier{modifier: unquote(modifier)}), do: unquote(value)
    end
  end

  defimpl AFK.ApplyKeycode, for: AFK.Keycode.Modifier do
    @spec apply_keycode(AFK.Keycode.Modifier.t(), AFK.State.t(), atom) :: AFK.State.t()
    def apply_keycode(keycode, state, key) do
      modifier_used? =
        Enum.any?(state.modifiers, fn
          {_key, ^keycode} -> true
          _ -> false
        end)

      if modifier_used? do
        state
      else
        modifiers = [{key, keycode} | state.modifiers]

        %{state | modifiers: modifiers}
      end
    end

    @spec unapply_keycode(AFK.Keycode.Modifier.t(), AFK.State.t(), atom) :: AFK.State.t()
    def unapply_keycode(keycode, state, key) do
      modifiers =
        Enum.filter(state.modifiers, fn
          {^key, ^keycode} -> false
          _ -> true
        end)

      %{state | modifiers: modifiers}
    end
  end
end
