defmodule AFK.Keycode.None do
  @moduledoc """
  Represents a key that does nothing when pressed.
  """

  defstruct []

  @doc """
  Creates a `None` keycode.
  """
  def new, do: %__MODULE__{}

  defimpl AFK.ApplyKeycode do
    def apply_keycode(_keycode, state, _key) do
      state
    end

    def unapply_keycode(_keycode, state, _key) do
      state
    end
  end
end
