defmodule AFK.Keymap do
  @moduledoc """
  A keymap represents the virtual key layout of a keyboard.

  It can be made up of multiple layers that can be activated and deactivated by
  pressing `AFK.Layer` keycodes.

  A keymap just needs to be a list of maps, where each map is a mapping of
  physical key identifier (usually an atom), to a `AFK.Keycodes.Keycodes`.

  For example:

      [
        # Layer 0 (default)
        %{
          k001: AFK.Keycodes.Key.new(:a),
          k002: AFK.Keycodes.Modifier.new(:left_control),
          k003: AFK.Keycodes.Layer.new(:hold, 1),
          k004: AFK.Keycodes.Key.new(:caps_lock)
        },
        # Layer 1
        %{
          k001: AFK.Keycodes.Key.new(:z),
          k002: AFK.Keycodes.Modifier.new(:right_super),
          k003: AFK.Keycodes.None.new(),
          k004: AFK.Keycodes.Transparent.new()
        }
      ]
  """

  @doc """
  Loads a keymap from a file.
  """
  def load_from_file!(filename) do
    filename
    |> File.read!()
    |> :erlang.binary_to_term()
  end

  @doc """
  Saves a keymap to a file.
  """
  def save_to_file!(keymap, filename) do
    keymap
    |> :erlang.term_to_binary()
    |> (&File.write!(filename, &1)).()
  end
end
