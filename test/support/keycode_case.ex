defmodule Keyboard.KeycodeCase do
  use ExUnit.CaseTemplate
  use Bitwise

  alias Keyboard.State
  alias Keyboard.Keycodes.{Key, Modifier}

  using do
    quote do
      import Keyboard.KeycodeCase, only: [assert_6kr: 2, assert_modifiers: 2]
    end
  end

  # checks that the HID report is as expected; assumes `keys` is a list of `Key`
  # structs or zeros, not any other kind of keycode.
  def assert_6kr(state, keys) do
    [one, two, three, four, five, six] =
      Enum.map(keys, fn
        0 -> 0
        %Key{value: value} -> value
      end)

    assert <<_, 0, ^one, ^two, ^three, ^four, ^five, ^six>> = State.to_hid_report(state)
  end

  # asserts the listed modifiers are active in the HID report.
  def assert_modifiers(state, modifiers) do
    modifier_byte =
      Enum.reduce(modifiers, 0, fn %Modifier{value: value}, acc -> value ||| acc end)

    assert <<^modifier_byte, 0, _, _, _, _, _, _>> = State.to_hid_report(state)
  end
end
