defmodule AFK.Keycodes.None do
  @moduledoc """
  Represents a key that does nothing when pressed.
  """

  defstruct []

  @doc """
  Creates a `None` keycode.
  """
  def new, do: %__MODULE__{}
end
