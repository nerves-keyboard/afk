defimpl Keyboard.State.ApplyKeycode, for: Keyboard.Keycodes.Modifier do
  def apply_keycode(modifier, state, key) do
    modifier_used? =
      Enum.any?(state.modifiers, fn
        {_key, ^modifier} -> true
        _ -> false
      end)

    if modifier_used? do
      state
    else
      modifiers = Map.put(state.modifiers, key, modifier)

      %{state | modifiers: modifiers}
    end
  end

  def unapply_keycode(modifier, state, key) do
    modifiers =
      state.modifiers
      |> Enum.filter(fn
        {^key, ^modifier} -> false
        _ -> true
      end)
      |> Map.new()

    %{state | modifiers: modifiers}
  end
end
