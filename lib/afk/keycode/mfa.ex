defmodule AFK.Keycode.MFA do
  @moduledoc """
  MFA allows you to call arbitrary Elixir code from key presses.
  """

  defstruct [:pressed_mfa, :released_mfa]

  @type mfargs :: {module, atom} | {module, atom, list}

  @type t :: %__MODULE__{
          pressed_mfa: mfargs,
          released_mfa: nil | mfargs
        }

  @doc """
  Creates an `MFA` keycode.

  ## Examples

  In this example, the keycode will call `MyMod.my_func/0` when pressed, and
  nothing when released.

      iex> new({MyMod, :my_func})
      %AFK.Keycode.MFA{pressed_mfa: {MyMod, :my_func}}
  """
  @spec new(pressed_mfa :: mfargs, released_mfa :: nil | mfargs) :: t
  def new(pressed_mfa, released_mfa \\ nil) do
    struct!(__MODULE__,
      pressed_mfa: pressed_mfa,
      released_mfa: released_mfa
    )
  end

  defimpl AFK.ApplyKeycode do
    @spec apply_keycode(keycode :: AFK.Keycode.MFA.t(), state :: AFK.State.t(), key :: atom) :: AFK.State.t()
    def apply_keycode(keycode, state, _key) do
      case keycode.pressed_mfa do
        {module, function, args} -> apply(module, function, args)
        {module, function} -> apply(module, function, [])
      end

      state
    end

    @spec unapply_keycode(keycode :: AFK.Keycode.MFA.t(), state :: AFK.State.t(), key :: atom) :: AFK.State.t()
    def unapply_keycode(keycode, state, _key) do
      case keycode.released_mfa do
        {module, function, args} -> apply(module, function, args)
        {module, function} -> apply(module, function, [])
        nil -> :noop
      end

      state
    end
  end
end
