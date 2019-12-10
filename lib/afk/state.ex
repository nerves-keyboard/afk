defmodule AFK.State do
  @moduledoc """
  A struct representing the current state of the keyboard.

  The state is initialized with a list of physical key to keycode maps
  representing the desired layers. The first layer is assumed to be the active
  default.

  The keyboard state can be modified by calling `press_key/2` and
  `release_key/2` with physical key IDs.

  The state can then be turned into a HID report byte string using
  `to_hid_report/1`.
  """

  use Bitwise

  alias AFK.State.Keymap

  import AFK.ApplyKeycode, only: [apply_keycode: 3, unapply_keycode: 3]
  import AFK.Scancode, only: [scancode: 1]

  @enforce_keys [:keys, :keymap, :modifiers, :six_keys]
  defstruct [:keys, :keymap, :modifiers, :six_keys]

  @doc """
  Returns a new state struct initialized with the given keymap.
  """
  def new(keymap) do
    struct!(__MODULE__,
      keys: %{},
      keymap: Keymap.new(keymap),
      modifiers: %{},
      six_keys: [nil, nil, nil, nil, nil, nil]
    )
  end

  @doc """
  Adds a key being pressed.
  """
  def press_key(%__MODULE__{} = state, key) do
    if Map.has_key?(state.keys, key), do: raise("Already pressed key pressed again! #{key}")

    keycode = Keymap.find_keycode(state.keymap, key)
    state = %{state | keys: Map.put(state.keys, key, keycode)}

    apply_keycode(keycode, state, key)
  end

  @doc """
  Releases a key being pressed.
  """
  def release_key(%__MODULE__{} = state, key) do
    if !Map.has_key?(state.keys, key), do: raise("Unpressed key released! #{key}")

    %{^key => keycode} = state.keys
    keys = Map.delete(state.keys, key)
    state = %{state | keys: keys}

    unapply_keycode(keycode, state, key)
  end

  @doc """
  Return the keyboard state to as a 6-key USB keyboard HID report.
  """
  def to_hid_report(%__MODULE__{} = state) do
    modifiers_byte =
      Enum.reduce(state.modifiers, 0, fn {_, keycode}, acc ->
        scancode(keycode) ||| acc
      end)

    [one, two, three, four, five, six] =
      Enum.map(state.six_keys, fn
        nil -> 0
        {_, keycode} -> scancode(keycode)
      end)

    <<modifiers_byte, 0, one, two, three, four, five, six>>
  end
end
