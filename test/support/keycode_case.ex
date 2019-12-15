defmodule AFK.KeycodeCase do
  @moduledoc false

  use ExUnit.CaseTemplate
  use Bitwise

  alias AFK.State
  alias AFK.Keycode.{Key, Modifier}

  import AFK.Scancode, only: [scancode: 1]

  using do
    quote do
      import AFK.KeycodeCase, only: [assert_6kr: 2, assert_modifiers: 2]
    end
  end

  # checks that the HID report is as expected; assumes `keys` is a list of `Key`
  # structs or zeros, not any other kind of keycode.
  @spec assert_6kr(AFK.State.t(), [0 | AFK.Keycode.Key.t()]) :: <<_::64>>
  def assert_6kr(state, keys) do
    [one, two, three, four, five, six] =
      Enum.map(keys, fn
        0 -> 0
        %Key{} = keycode -> scancode(keycode)
      end)

    assert <<_, 0, ^one, ^two, ^three, ^four, ^five, ^six>> = State.to_hid_report(state)
  end

  # asserts the listed modifiers are active in the HID report.
  @spec assert_modifiers(AFK.State.t(), [AFK.Keycode.Modifier.t()]) :: <<_::64>>
  def assert_modifiers(state, modifiers) do
    modifier_byte = Enum.reduce(modifiers, 0, fn %Modifier{} = keycode, acc -> scancode(keycode) ||| acc end)

    assert <<^modifier_byte, 0, _, _, _, _, _, _>> = State.to_hid_report(state)
  end
end
