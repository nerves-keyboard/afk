defmodule AFK.Keycode.Transparent do
  @moduledoc """
  Represents a key that is transparent to its layer.

  Any key-press it registers falls to lower layers, of any.
  """

  defstruct []

  @doc """
  Creates a `Transparent` keycode.
  """
  def new, do: %__MODULE__{}
end
