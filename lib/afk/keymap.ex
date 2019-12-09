defmodule AFK.Keymap do
  def load_from_file!(filename) do
    filename
    |> File.read!()
    |> :erlang.binary_to_term()
  end

  def save_to_file!(keymap, filename) do
    keymap
    |> :erlang.term_to_binary()
    |> (&File.write!(filename, &1)).()
  end
end
