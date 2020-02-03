defmodule AFK.State do
  @moduledoc """
  A process representing the current state of the keyboard.

  The state is initialized with a list of physical key to keycode maps
  representing the desired layers. The first layer is assumed to be the active
  default.

  TODO: describe extra args

  The keyboard state can be modified by calling `press_key/2` and
  `release_key/2` with physical key IDs.
  """

  use GenServer

  alias AFK.ApplyKeycode
  alias AFK.State.Keymap

  @enforce_keys [
    :event_receiver,
    :hid_report_mod,
    :indexed_keys,
    :keymap,
    :keys,
    :last_hid_report,
    :locked_keys,
    :modifiers,
    :pending_lock?
  ]
  defstruct [
    :event_receiver,
    :hid_report_mod,
    :indexed_keys,
    :keymap,
    :keys,
    :last_hid_report,
    :locked_keys,
    :modifiers,
    :pending_lock?
  ]

  @type t :: %__MODULE__{
          event_receiver: pid,
          hid_report_mod: atom,
          indexed_keys: %{non_neg_integer => {atom, AFK.Keycode.Key.t()}},
          keymap: Keymap.t(),
          keys: %{atom => AFK.Keycode.t()},
          last_hid_report: nil | binary(),
          locked_keys: [{atom, AFK.Keycode.t()}],
          modifiers: [{atom, AFK.Keycode.Modifier.t()}],
          pending_lock?: boolean()
        }

  # Client

  # TODO: spec
  # TODO: docs
  def start_link(args, opts \\ []) do
    [
      event_receiver: event_receiver,
      keymap: keymap,
      hid_report_mod: hid_report_mod
    ] = args

    state =
      struct!(__MODULE__,
        event_receiver: event_receiver,
        hid_report_mod: hid_report_mod,
        indexed_keys: %{},
        keymap: Keymap.new(keymap),
        keys: %{},
        last_hid_report: nil,
        locked_keys: [],
        modifiers: [],
        pending_lock?: false
      )

    GenServer.start_link(__MODULE__, state, opts)
  end

  @doc """
  Presses a key.
  """
  # TODO: spec
  def press_key(pid, key) do
    GenServer.cast(pid, {:press_key, key})
  end

  @doc """
  Releases a key being pressed.
  """
  # TODO: spec
  def release_key(pid, key) do
    GenServer.cast(pid, {:release_key, key})
  end

  # Server

  @doc false
  # TODO: spec
  def init(state) do
    state = report!(state)
    {:ok, state}
  end

  @doc false
  # TODO: spec
  def handle_cast({:press_key, key}, state) do
    if Map.has_key?(state.keys, key), do: raise("Already pressed key pressed again! #{key}")

    keycode = Keymap.find_keycode(state.keymap, key)
    state = %{state | keys: Map.put(state.keys, key, keycode)}
    state = handle_key_locking(state, key, keycode)

    state = ApplyKeycode.apply_keycode(keycode, state, key)

    state = report!(state)

    {:noreply, state}
  end

  @doc false
  # TODO: spec
  def handle_cast({:release_key, key}, %__MODULE__{} = state) do
    if !Map.has_key?(state.keys, key), do: raise("Unpressed key released! #{key}")

    %{^key => keycode} = state.keys
    keys = Map.delete(state.keys, key)
    state = %{state | keys: keys}

    state =
      if keycode in Keyword.get_values(state.locked_keys, key) do
        state
      else
        ApplyKeycode.unapply_keycode(keycode, state, key)
      end

    state = report!(state)

    {:noreply, state}
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

  defp report!(state) do
    hid_report = state.hid_report_mod.hid_report(state)

    if state.last_hid_report != hid_report do
      send(state.event_receiver, {:hid_report, hid_report})

      %{state | last_hid_report: hid_report}
    else
      state
    end
  end
end
