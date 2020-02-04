defmodule AFK.Keycode.None do
  @moduledoc """
  Represents a key that does nothing when pressed.
  """

  defstruct []

  @type t :: %__MODULE__{}

  @doc """
  Creates a `None` keycode.

  ## Examples

      iex> new()
      %AFK.Keycode.None{}
  """
  @spec new :: t
  def new, do: %__MODULE__{}

  defimpl AFK.ApplyKeycode do
    @spec apply_keycode(keycode :: AFK.Keycode.None.t(), state :: AFK.State.t(), key :: atom) :: AFK.State.t()
    def apply_keycode(_keycode, state, _key) do
      state
    end

    @spec unapply_keycode(keycode :: AFK.Keycode.None.t(), state :: AFK.State.t(), key :: atom) :: AFK.State.t()
    def unapply_keycode(_keycode, state, _key) do
      state
    end
  end
end
