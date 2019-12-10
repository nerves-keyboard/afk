defmodule AFK.KeycodeCase do
  @moduledoc false

  use ExUnit.CaseTemplate
  use Bitwise

  alias AFK.State
  alias AFK.Keycodes.{Key, Modifier}

  import AFK.Keycodes.HIDValue, only: [hid_value: 1]

  using do
    quote do
      import AFK.KeycodeCase, only: [assert_6kr: 2, assert_modifiers: 2]
    end
  end

  # checks that the HID report is as expected; assumes `keys` is a list of `Key`
  # structs or zeros, not any other kind of keycode.
  def assert_6kr(state, keys) do
    [one, two, three, four, five, six] =
      Enum.map(keys, fn
        0 -> 0
        %Key{} = keycode -> hid_value(keycode)
      end)

    assert <<_, 0, ^one, ^two, ^three, ^four, ^five, ^six>> = State.to_hid_report(state)
  end

  # asserts the listed modifiers are active in the HID report.
  def assert_modifiers(state, modifiers) do
    modifier_byte = Enum.reduce(modifiers, 0, fn %Modifier{} = keycode, acc -> hid_value(keycode) ||| acc end)

    assert <<^modifier_byte, 0, _, _, _, _, _, _>> = State.to_hid_report(state)
  end
end
