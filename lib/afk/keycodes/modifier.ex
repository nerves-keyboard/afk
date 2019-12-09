defmodule AFK.Keycodes.Modifier do
  @enforce_keys [:id, :value]
  defstruct [:id, :value]

  @modifiers [
    {0x01, :left_control},
    {0x02, :left_shift},
    {0x04, :left_alt},
    {0x08, :left_super},
    {0x10, :right_control},
    {0x20, :right_shift},
    {0x40, :right_alt},
    {0x80, :right_super}
  ]

  @doc """
  Gets a modifier keycode by its ID.

  A modifier ID is an `Atom`, e.g. `:left_control`. This function returns a
  modifier keycode by a given ID.

  ## Examples

      iex> from_id!(:left_control)
      %AFK.Keycodes.Modifier{id: :left_control, value: 1}

      iex> from_id!(:right_super)
      %AFK.Keycodes.Modifier{id: :right_super, value: 128}
  """
  def from_id!(id)

  for {value, id} <- @modifiers do
    def from_id!(unquote(id)) do
      struct!(__MODULE__,
        id: unquote(id),
        value: unquote(value)
      )
    end
  end

  def from_id!(id), do: raise("Invalid Modifier ID: #{id}")
end
