defmodule Keyboard.State do
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

  alias Keyboard.State.ApplyKeycode
  alias Keyboard.Keycodes.{None, Transparent}

  defstruct keys: %{},
            layers: [],
            modifiers: %{},
            six_keys: [nil, nil, nil, nil, nil, nil]

  @doc """
  Returns a new state struct initialized with the given keymap.
  """
  def new(keymap) do
    layers =
      keymap
      |> Enum.map(fn layer ->
        %{
          active: false,
          activations: %{},
          layer: layer
        }
      end)
      |> put_in([Access.at(0), :active], true)
      |> put_in([Access.at(0), :activations, :default], true)
      |> Enum.reverse()

    struct!(__MODULE__, layers: layers)
  end

  @doc """
  Adds a key being pressed.
  """
  def press_key(%__MODULE__{} = state, key) do
    if Map.has_key?(state.keys, key), do: raise("Already pressed key pressed again! #{key}")

    keycode = find_keycode(state.layers, key)
    state = %{state | keys: Map.put(state.keys, key, keycode)}

    ApplyKeycode.apply_keycode(keycode, state, key)
  end

  defp find_keycode(layers, key) do
    Enum.find_value(layers, %None{}, fn
      %{active: true, layer: %{^key => %Transparent{}}} -> false
      %{active: true, layer: %{^key => keycode}} -> keycode
      _else -> false
    end)
  end

  @doc """
  Releases a key being pressed.
  """
  def release_key(%__MODULE__{} = state, key) do
    if !Map.has_key?(state.keys, key), do: raise("Unpressed key released! #{key}")

    %{^key => keycode} = state.keys
    keys = Map.delete(state.keys, key)
    state = %{state | keys: keys}

    ApplyKeycode.unapply_keycode(keycode, state, key)
  end

  @doc """
  Dump keyboard state to HID report.
  """
  def to_hid_report(%__MODULE__{} = state) do
    modifiers_byte =
      Enum.reduce(state.modifiers, 0, fn {_, keycode}, acc ->
        keycode.value ||| acc
      end)

    [one, two, three, four, five, six] =
      Enum.map(state.six_keys, fn
        nil -> 0
        {_, %{value: value}} -> value
      end)

    <<modifiers_byte, 0, one, two, three, four, five, six>>
  end
end
