defmodule AFK.State do
  @moduledoc """
  A struct representing the current state of the keyboard.

  The state is initialized with a list of physical key to keycode maps
  representing the desired layers. The first layer is assumed to be the active
  default.

  The keyboard state can be modified by calling `press_key/2` and
  `release_key/2` with physical key IDs.

  The state can then be turned into a binary HID report byte string using an
  implementation of the `AFK.HIDReport` behaviour.
  """

  import AFK.ApplyKeycode, only: [apply_keycode: 3, unapply_keycode: 3]

  alias AFK.State.Keymap

  @enforce_keys [:indexed_keys, :keymap, :keys, :modifiers, :locked_keys, :pending_lock?]
  defstruct [:indexed_keys, :keymap, :keys, :modifiers, :locked_keys, :pending_lock?]

  @type t :: %__MODULE__{
          indexed_keys: %{non_neg_integer => {atom, AFK.Keycode.Key.t()}},
          keymap: Keymap.t(),
          keys: %{atom => AFK.Keycode.t()},
          modifiers: [{atom, AFK.Keycode.Modifier.t()}],
          locked_keys: [{atom, AFK.Keycode.t()}],
          pending_lock?: boolean()
        }

  @doc """
  Returns a new state struct initialized with the given keymap.
  """
  @spec new(AFK.Keymap.t()) :: t
  def new(keymap) do
    struct!(__MODULE__,
      indexed_keys: %{},
      keymap: Keymap.new(keymap),
      keys: %{},
      modifiers: [],
      locked_keys: [],
      pending_lock?: false
    )
  end

  @doc """
  Presses a key.
  """
  @spec press_key(t, atom) :: t
  def press_key(%__MODULE__{} = state, key) do
    if Map.has_key?(state.keys, key), do: raise("Already pressed key pressed again! #{key}")

    keycode = Keymap.find_keycode(state.keymap, key)
    state = %{state | keys: Map.put(state.keys, key, keycode)}
    state = handle_key_locking(state, key, keycode)

    apply_keycode(keycode, state, key)
  end

  defp handle_key_locking(state, _key, %AFK.Keycode.KeyLock{}), do: state

  defp handle_key_locking(%__MODULE__{pending_lock?: true} = state, key, keycode) do
    locked_keys = [{key, keycode} | state.locked_keys]

    %{state | locked_keys: locked_keys, pending_lock?: false}
  end

  defp handle_key_locking(state, key, keycode) do
    if Keyword.has_key?(state.locked_keys, key) do
      locked_keys =
        Enum.filter(state.locked_keys, fn
          {^key, ^keycode} -> false
          _ -> true
        end)

      %{state | locked_keys: locked_keys}
    else
      state
    end
  end

  @doc """
  Releases a key being pressed.
  """
  @spec release_key(t, atom) :: t
  def release_key(%__MODULE__{} = state, key) do
    if !Map.has_key?(state.keys, key), do: raise("Unpressed key released! #{key}")

    %{^key => keycode} = state.keys
    keys = Map.delete(state.keys, key)
    state = %{state | keys: keys}

    if keycode in Keyword.get_values(state.locked_keys, key) do
      state
    else
      unapply_keycode(keycode, state, key)
    end
  end
end
