defmodule AFK.Keycode.Transparent do
  @moduledoc """
  Represents a key that is transparent to its layer.

  Any key-press it registers falls to lower layers, of any.
  """

  defstruct []

  @type t :: %__MODULE__{}

  @doc """
  Creates a `Transparent` keycode.


  ## Examples

      iex> new()
      %AFK.Keycode.Transparent{}
  """
  @spec new :: t
  def new, do: %__MODULE__{}
end
