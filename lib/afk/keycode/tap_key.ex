defmodule AFK.Keycode.TapKey do
  @moduledoc """
  TODO:
  """

  @enforce_keys [:hold, :tap, :timeout]
  defstruct [:hold, :tap, :timeout]

  @type t :: %__MODULE__{
          hold: AFK.Keycode.t(),
          tap: AFK.Keycode.t(),
          timeout: pos_integer
        }

  @doc """
  TODO:
  """
  @spec new(hold :: AFK.Keycode.t(), tap :: AFK.Keycode.t(), timeout :: pos_integer) :: t
  def new(hold, tap, timeout \\ 50) when timeout > 0 do
    struct!(__MODULE__, hold: hold, tap: tap, timeout: timeout)
  end

  defimpl AFK.ApplyKeycode do
    @spec apply_keycode(AFK.Keycode.TapKey.t(), AFK.State.t(), atom) :: AFK.State.t()
    def apply_keycode(keycode, state, key) do
      %{hold: hold_keycode, tap: tap_keycode, timeout: timeout} = keycode

      message_to_wait_for = {:release_key, key}

      timer = Process.send_after(self(), {:clear_wait, message_to_wait_for}, timeout)

      if Map.has_key?(state.waiting_on, message_to_wait_for), do: raise("duplicate waiting on")

      %{
        state
        | waiting_on:
            Map.put(state.waiting_on, message_to_wait_for, %{
              resolve: fn ->
                # the message we were waiting for arrived
                # return the tap variant and cancel the timer
                Process.cancel_timer(timer)

                {key, tap_keycode}
              end,
              timeout: fn ->
                # the message we were waiting for did not arrive
                # return the hold variant
                {key, hold_keycode}
              end
            })
      }
    end

    @spec unapply_keycode(AFK.Keycode.TapKey.t(), AFK.State.t(), atom) :: AFK.State.t()
    def unapply_keycode(_keycode, _state, _key) do
      raise "should never be called"
    end
  end
end
