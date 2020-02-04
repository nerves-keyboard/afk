defmodule AFK.Keycode.KeyLock do
  @moduledoc """
  KeyLock allows you to lock any key as if you were holding it down.

  Pressing the KeyLock key first, and then any other key, will lock the second
  key as if it were being held down. Think of this like Caps Lock, but for any
  key.
  """

  defstruct []

  @type t :: %__MODULE__{}

  @doc """
  Creates a `KeyLock` keycode.

  ## Examples

      iex> new()
      %AFK.Keycode.KeyLock{}
  """
  @spec new :: t
  def new, do: %__MODULE__{}

  defimpl AFK.ApplyKeycode do
    @spec apply_keycode(keycode :: AFK.Keycode.KeyLock.t(), state :: AFK.State.t(), key :: atom) :: AFK.State.t()
    def apply_keycode(_keycode, state, _key) do
      %{state | pending_lock?: !state.pending_lock?}
    end

    @spec unapply_keycode(keycode :: AFK.Keycode.KeyLock.t(), state :: AFK.State.t(), key :: atom) :: AFK.State.t()
    def unapply_keycode(_keycode, state, _key) do
      state
    end
  end
end
