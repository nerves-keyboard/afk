defmodule AFK.Keymap do
  @moduledoc """
  A keymap represents the virtual key layout of a keyboard.

  It can be made up of multiple layers that can be activated and deactivated by
  pressing `AFK.Layer` keycodes.

  A keymap just needs to be a list of maps, where each map is a mapping of
  physical key identifier (usually an atom), to a `AFK.Keycode.Keycode`.

  For example:

      [
        # Layer 0 (default)
        %{
          k001: AFK.Keycode.Key.new(:a),
          k002: AFK.Keycode.Modifier.new(:left_control),
          k003: AFK.Keycode.Layer.new(:hold, 1),
          k004: AFK.Keycode.Key.new(:caps_lock)
        },
        # Layer 1
        %{
          k001: AFK.Keycode.Key.new(:z),
          k002: AFK.Keycode.Modifier.new(:right_super),
          k003: AFK.Keycode.None.new(),
          k004: AFK.Keycode.Transparent.new()
        }
      ]
  """
  @type layer :: %{
          atom => AFK.Keycode.t()
        }

  @type t :: [layer]

  @doc """
  Loads a keymap from a file.
  """
  @spec load_from_file!(binary) :: t
  def load_from_file!(filename) do
    filename
    |> File.read!()
    |> :erlang.binary_to_term()
  end

  @doc """
  Saves a keymap to a file.
  """
  @spec save_to_file!(t, binary) :: :ok
  def save_to_file!(keymap, filename) do
    keymap
    |> :erlang.term_to_binary()
    |> (&File.write!(filename, &1)).()
  end
end
