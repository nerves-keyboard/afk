defmodule AFK.State do
  @moduledoc """
  A GenServer process representing the current state of the keyboard.

  The process can effectively be thought of as a realtime stream manipulator. It
  receives key press and key release events (through `press_key/2` and
  `release_key/2` respectively) and transforms them into an outgoing event
  stream of HID reports.

  The process will send message of the form `{:hid_report, hid_report}` to the
  given `:event_receiver` pid.
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
    :pending_lock?,
    :pending_messages,
    :waiting_on
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
    :pending_lock?,
    :pending_messages,
    :waiting_on
  ]

  @type t :: %__MODULE__{
          event_receiver: pid,
          hid_report_mod: atom,
          indexed_keys: %{non_neg_integer => {atom, AFK.Keycode.Key.t()}},
          keymap: Keymap.t(),
          keys: %{atom => AFK.Keycode.t()},
          last_hid_report: nil | binary,
          locked_keys: [{atom, AFK.Keycode.t()}],
          modifiers: [{atom, AFK.Keycode.Modifier.t()}],
          pending_lock?: boolean,
          # TODO: types
          pending_messages: list(any),
          waiting_on: any
        }

  @type args :: [
          event_receiver: pid,
          keymap: AFK.Keymap.t(),
          hid_report_mod: atom
        ]

  # Client

  @doc """
  Starts the state GenServer.

  The three required arguments (in the form of a keyword list) are:

  * `:event_receiver` - A PID to send the HID reports to.
  * `:keymap` - The keymap to use (see `AFK.Keymap` for details).
  * `:hid_report_mod` - A module that implements the `AFK.HIDReport` behaviour.
  """
  @spec start_link(args, opts :: GenServer.options()) :: GenServer.on_start()
  def start_link(args, opts \\ []) do
    event_receiver = Keyword.fetch!(args, :event_receiver)
    keymap = Keyword.fetch!(args, :keymap)
    hid_report_mod = Keyword.fetch!(args, :hid_report_mod)

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
        pending_lock?: false,
        pending_messages: [],
        waiting_on: %{}
      )

    GenServer.start_link(__MODULE__, state, opts)
  end

  @doc """
  Presses a key.

  The given key must not already be being pressed, otherwise the server will
  crash.
  """
  @spec press_key(server :: GenServer.server(), key :: atom) :: :ok
  def press_key(server, key) do
    GenServer.cast(server, {:press_key, key})
  end

  @doc """
  Releases a key being pressed.

  The given key must be being pressed, otherwise the server will crash.
  """
  @spec release_key(server :: GenServer.server(), key :: atom) :: :ok
  def release_key(server, key) do
    GenServer.cast(server, {:release_key, key})
  end

  # Server

  @doc false
  @spec init(state :: AFK.State.t()) :: {:ok, AFK.State.t()}
  def init(state) do
    state = report!(state)
    {:ok, state}
  end

  @doc false
  @spec handle_cast(message :: {:press_key | :release_key, atom}, state :: AFK.State.t()) :: {:noreply, AFK.State.t()}
  def handle_cast(message, state) do
    state =
      case state.waiting_on do
        %{^message => callbacks} ->
          {key, keycode} = callbacks.resolve.()
          state = %{state | waiting_on: Map.delete(state.waiting_on, message)}

          # overwrites pressed key with resolved keycode
          state = %{state | keys: Map.put(state.keys, key, keycode)}

          state = handle_key_locking(state, key, keycode)

          state = ApplyKeycode.apply_keycode(keycode, state, key)

          report!(state)

        %{} = waiting_on when map_size(waiting_on) == 0 ->
          state

        _else ->
          state
      end

    send(self(), :flush)

    {:noreply, %{state | pending_messages: state.pending_messages ++ [message]}}
  end

  @doc false
  def handle_info(:flush, %{pending_messages: []} = state) do
    {:noreply, state}
  end

  def handle_info(:flush, state) do
    if state.waiting_on != %{} do
      {:noreply, state}
    else
      [message | rest] = state.pending_messages

      state =
        case message do
          {:press_key, key} ->
            handle_press_key(key, state)

          {:release_key, key} ->
            handle_release_key(key, state)
        end

      send(self(), :flush)

      {:noreply, %{state | pending_messages: rest}}
    end
  end

  def handle_info({:clear_wait, message}, state) do
    send(self(), :flush)

    %{waiting_on: %{^message => callbacks}} = state
    {key, keycode} = callbacks.timeout.()
    state = %{state | waiting_on: Map.delete(state.waiting_on, message)}

    # overwrites pressed key with resolved keycode
    state = %{state | keys: Map.put(state.keys, key, keycode)}

    state = handle_key_locking(state, key, keycode)

    state = ApplyKeycode.apply_keycode(keycode, state, key)

    state = report!(state)

    {:noreply, state}
  end

  defp handle_press_key(key, state) do
    if Map.has_key?(state.keys, key), do: raise("Already pressed key pressed again! #{key}")

    keycode = Keymap.find_keycode(state.keymap, key)
    state = %{state | keys: Map.put(state.keys, key, keycode)}
    state = handle_key_locking(state, key, keycode)

    state = ApplyKeycode.apply_keycode(keycode, state, key)

    report!(state)
  end

  defp handle_key_locking(state, _key, %AFK.Keycode.KeyLock{}), do: state
  defp handle_key_locking(state, _key, %AFK.Keycode.TapKey{}), do: state

  defp handle_key_locking(%__MODULE__{pending_lock?: true} = state, key, keycode) do
    locked_keys = [{key, keycode} | state.locked_keys]

    %{state | locked_keys: locked_keys, pending_lock?: false}
  end

  defp handle_key_locking(state, key, keycode) do
    if Keyword.has_key?(state.locked_keys, key) do
      locked_keys =
        Enum.filter(state.locked_keys, fn
          {^key, ^keycode} -> false
          {_key, _keycode} -> true
        end)

      %{state | locked_keys: locked_keys}
    else
      state
    end
  end

  defp handle_release_key(key, state) do
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

    report!(state)
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
