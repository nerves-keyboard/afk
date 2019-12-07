defimpl Keyboard.State.ApplyKeycode, for: Keyboard.Keycodes.Key do
  def apply_keycode(keycode, state, key) do
    keycode_used? =
      Enum.any?(state.six_keys, fn
        nil -> false
        {_, kc} -> kc == keycode
      end)

    if keycode_used? do
      state
    else
      {six_keys, _} =
        Enum.map_reduce(state.six_keys, keycode, fn
          x, nil -> {x, nil}
          nil, kc -> {{key, kc}, nil}
          x, kc -> {x, kc}
        end)

      %{state | six_keys: six_keys}
    end
  end

  def unapply_keycode(keycode, state, key) do
    six_keys =
      Enum.map(state.six_keys, fn
        {^key, ^keycode} -> nil
        x -> x
      end)

    %{state | six_keys: six_keys}
  end
end
