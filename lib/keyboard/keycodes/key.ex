defmodule Keyboard.Keycodes.Key do
  @enforce_keys [:id, :value]
  defstruct [:id, :value]

  @keys [
    {0x04, :a},
    {0x05, :b},
    {0x06, :c},
    {0x07, :d},
    {0x08, :e},
    {0x09, :f},
    {0x0A, :g},
    {0x0B, :h},
    {0x0C, :i},
    {0x0D, :j},
    {0x0E, :k},
    {0x0F, :l},
    {0x10, :m},
    {0x11, :n},
    {0x12, :o},
    {0x13, :p},
    {0x14, :q},
    {0x15, :r},
    {0x16, :s},
    {0x17, :t},
    {0x18, :u},
    {0x19, :v},
    {0x1A, :w},
    {0x1B, :x},
    {0x1C, :y},
    {0x1D, :z},
    {0x1E, :"1"},
    {0x1F, :"2"},
    {0x20, :"3"},
    {0x21, :"4"},
    {0x22, :"5"},
    {0x23, :"6"},
    {0x24, :"7"},
    {0x25, :"8"},
    {0x26, :"9"},
    {0x27, :"0"},
    {0x28, :enter},
    {0x29, :escape},
    {0x2A, :backspace},
    {0x2B, :tab},
    {0x2C, :space},
    {0x2D, :minus},
    {0x2E, :equals},
    {0x2F, :left_square_bracket},
    {0x30, :right_square_bracket},
    {0x31, :backslash},
    {0x33, :semicolon},
    {0x34, :single_quote},
    {0x35, :grave},
    {0x36, :comma},
    {0x37, :period},
    {0x38, :slash},
    {0x39, :caps_lock},
    {0x3A, :f1},
    {0x3B, :f2},
    {0x3C, :f3},
    {0x3D, :f4},
    {0x3E, :f5},
    {0x3F, :f6},
    {0x40, :f7},
    {0x41, :f8},
    {0x42, :f9},
    {0x43, :f10},
    {0x44, :f11},
    {0x45, :f12},
    {0x46, :print_screen},
    {0x47, :scroll_lock},
    {0x48, :pause},
    {0x49, :insert},
    {0x4A, :home},
    {0x4B, :page_up},
    {0x4C, :delete},
    {0x4D, :end},
    {0x4E, :page_down},
    {0x4F, :right},
    {0x50, :left},
    {0x51, :down},
    {0x52, :up},
    {0x65, :application}
  ]

  @doc """
  Gets a key keycode by its ID.

  A key keycode ID is an `Atom`, e.g. `:a`. This function returns a key keycode
  by a given ID.

  ## Examples

      iex> from_id!(:a)
      %Keyboard.Keycodes.Key{id: :a, value: 4}

      iex> from_id!(:up)
      %Keyboard.Keycodes.Key{id: :up, value: 82}
  """
  def from_id!(id)

  for {value, id} <- @keys do
    def from_id!(unquote(id)) do
      struct!(__MODULE__,
        id: unquote(id),
        value: unquote(value)
      )
    end
  end

  def from_id!(id), do: raise("Invalid Key ID: #{id}")
end
