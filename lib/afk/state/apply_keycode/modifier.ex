defimpl AFK.State.ApplyKeycode, for: AFK.Keycodes.Modifier do
  @moduledoc false

  def apply_keycode(keycode, state, key) do
    modifier_used? =
      Enum.any?(state.modifiers, fn
        {_key, ^keycode} -> true
        _ -> false
      end)

    if modifier_used? do
      state
    else
      modifiers = Map.put(state.modifiers, key, keycode)

      %{state | modifiers: modifiers}
    end
  end

  def unapply_keycode(keycode, state, key) do
    modifiers =
      state.modifiers
      |> Enum.filter(fn
        {^key, ^keycode} -> false
        _ -> true
      end)
      |> Map.new()

    %{state | modifiers: modifiers}
  end
end
