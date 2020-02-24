defmodule AFK.Scancode do
  @moduledoc false

  @keys [
    # 0x00 - No key pressed
    # 0x01 - Keyboard Error Roll Over
    # 0x02 - Keyboard POST Fail
    # 0x03 - Keyboard Error Undefined
    {0x04, :a},
    {0x05, :b},
    {0x06, :c},
    {0x07, :d},
    {0x08, :e},
    {0x09, :f},
    {0x0A, :g},
    {0x0B, :h},
    {0x0C, :i},
    {0x0D, :j},
    {0x0E, :k},
    {0x0F, :l},
    {0x10, :m},
    {0x11, :n},
    {0x12, :o},
    {0x13, :p},
    {0x14, :q},
    {0x15, :r},
    {0x16, :s},
    {0x17, :t},
    {0x18, :u},
    {0x19, :v},
    {0x1A, :w},
    {0x1B, :x},
    {0x1C, :y},
    {0x1D, :z},
    {0x1E, :"1"},
    {0x1F, :"2"},
    {0x20, :"3"},
    {0x21, :"4"},
    {0x22, :"5"},
    {0x23, :"6"},
    {0x24, :"7"},
    {0x25, :"8"},
    {0x26, :"9"},
    {0x27, :"0"},
    {0x28, :enter},
    {0x29, :escape},
    {0x2A, :backspace},
    {0x2B, :tab},
    {0x2C, :space},
    {0x2D, :minus},
    {0x2E, :equals},
    {0x2F, :left_square_bracket},
    {0x30, :right_square_bracket},
    {0x31, :backslash},
    # 0x32 - Keyboard Non-US # and ~
    {0x33, :semicolon},
    {0x34, :single_quote},
    {0x35, :grave},
    {0x36, :comma},
    {0x37, :period},
    {0x38, :slash},
    {0x39, :caps_lock},
    {0x3A, :f1},
    {0x3B, :f2},
    {0x3C, :f3},
    {0x3D, :f4},
    {0x3E, :f5},
    {0x3F, :f6},
    {0x40, :f7},
    {0x41, :f8},
    {0x42, :f9},
    {0x43, :f10},
    {0x44, :f11},
    {0x45, :f12},
    {0x46, :print_screen},
    {0x47, :scroll_lock},
    {0x48, :pause},
    {0x49, :insert},
    {0x4A, :home},
    {0x4B, :page_up},
    {0x4C, :delete},
    {0x4D, :end},
    {0x4E, :page_down},
    {0x4F, :right},
    {0x50, :left},
    {0x51, :down},
    {0x52, :up},
    # 0x53 - Keyboard Num Lock and Clear
    # 0x54 - Keypad /
    # 0x55 - Keypad *
    # 0x56 - Keypad -
    # 0x57 - Keypad +
    # 0x58 - Keypad ENTER
    # 0x59 - Keypad 1 and End
    # 0x5A - Keypad 2 and Down Arrow
    # 0x5B - Keypad 3 and PageDn
    # 0x5C - Keypad 4 and Left Arrow
    # 0x5D - Keypad 5
    # 0x5E - Keypad 6 and Right Arrow
    # 0x5F - Keypad 7 and Home
    # 0x60 - Keypad 8 and Up Arrow
    # 0x61 - Keypad 9 and Page Up
    # 0x62 - Keypad 0 and Insert
    # 0x63 - Keypad . and Delete
    # 0x64 - Keyboard Non-US \ and |
    {0x65, :application},
    # 0x66 - Keyboard Power
    # 0x67 - Keypad =
    # 0x68 - Keyboard F13
    # 0x69 - Keyboard F14
    # 0x6A - Keyboard F15
    # 0x6B - Keyboard F16
    # 0x6C - Keyboard F17
    # 0x6D - Keyboard F18
    # 0x6E - Keyboard F19
    # 0x6F - Keyboard F20
    # 0x70 - Keyboard F21
    # 0x71 - Keyboard F22
    # 0x72 - Keyboard F23
    # 0x73 - Keyboard F24
    # 0x74 - Keyboard Execute
    # 0x75 - Keyboard Help
    # 0x76 - Keyboard Menu
    # 0x77 - Keyboard Select
    # 0x78 - Keyboard Stop
    # 0x79 - Keyboard Again
    # 0x7A - Keyboard Undo
    # 0x7B - Keyboard Cut
    # 0x7C - Keyboard Copy
    # 0x7D - Keyboard Paste
    # 0x7E - Keyboard Find
    {0x7F, :mute},
    {0x80, :volume_up},
    {0x81, :volume_down}
    # 0x82 - Keyboard Locking Caps Lock
    # 0x83 - Keyboard Locking Num Lock
    # 0x84 - Keyboard Locking Scroll Lock
    # 0x85 - Keypad Comma
    # 0x86 - Keypad Equal Sign
    # 0x87 - Keyboard International1
    # 0x88 - Keyboard International2
    # 0x89 - Keyboard International3
    # 0x8A - Keyboard International4
    # 0x8B - Keyboard International5
    # 0x8C - Keyboard International6
    # 0x8D - Keyboard International7
    # 0x8E - Keyboard International8
    # 0x8F - Keyboard International9
    # 0x90 - Keyboard LANG1
    # 0x91 - Keyboard LANG2
    # 0x92 - Keyboard LANG3
    # 0x93 - Keyboard LANG4
    # 0x94 - Keyboard LANG5
    # 0x95 - Keyboard LANG6
    # 0x96 - Keyboard LANG7
    # 0x97 - Keyboard LANG8
    # 0x98 - Keyboard LANG9
    # 0x99 - Keyboard Alternate Erase
    # 0x9A - Keyboard SysReq/Attention
    # 0x9B - Keyboard Cancel
    # 0x9C - Keyboard Clear
    # 0x9D - Keyboard Prior
    # 0x9E - Keyboard Return
    # 0x9F - Keyboard Separator
    # 0xA0 - Keyboard Out
    # 0xA1 - Keyboard Oper
    # 0xA2 - Keyboard Clear/Again
    # 0xA3 - Keyboard CrSel/Props
    # 0xA4 - Keyboard ExSel
    # 0xA5 - ???
    # 0xA6 - ???
    # 0xA7 - ???
    # 0xA8 - ???
    # 0xA9 - ???
    # 0xAA - ???
    # 0xAB - ???
    # 0xAC - ???
    # 0xAD - ???
    # 0xAE - ???
    # 0xAF - ???
    # 0xB0 - Keypad 00
    # 0xB1 - Keypad 000
    # 0xB2 - Thousands Separator
    # 0xB3 - Decimal Separator
    # 0xB4 - Currency Unit
    # 0xB5 - Currency Sub-unit
    # 0xB6 - Keypad (
    # 0xB7 - Keypad )
    # 0xB8 - Keypad {
    # 0xB9 - Keypad }
    # 0xBA - Keypad Tab
    # 0xBB - Keypad Backspace
    # 0xBC - Keypad A
    # 0xBD - Keypad B
    # 0xBE - Keypad C
    # 0xBF - Keypad D
    # 0xC0 - Keypad E
    # 0xC1 - Keypad F
    # 0xC2 - Keypad XOR
    # 0xC3 - Keypad ^
    # 0xC4 - Keypad %
    # 0xC5 - Keypad <
    # 0xC6 - Keypad >
    # 0xC7 - Keypad &
    # 0xC8 - Keypad &&
    # 0xC9 - Keypad |
    # 0xCA - Keypad ||
    # 0xCB - Keypad :
    # 0xCC - Keypad #
    # 0xCD - Keypad Space
    # 0xCE - Keypad @
    # 0xCF - Keypad !
    # 0xD0 - Keypad Memory Store
    # 0xD1 - Keypad Memory Recall
    # 0xD2 - Keypad Memory Clear
    # 0xD3 - Keypad Memory Add
    # 0xD4 - Keypad Memory Subtract
    # 0xD5 - Keypad Memory Multiply
    # 0xD6 - Keypad Memory Divide
    # 0xD7 - Keypad +/-
    # 0xD8 - Keypad Clear
    # 0xD9 - Keypad Clear Entry
    # 0xDA - Keypad Binary
    # 0xDB - Keypad Octal
    # 0xDC - Keypad Decimal
    # 0xDD - Keypad Hexadecimal
  ]

  @modifiers [
    {0x01, :left_control},
    {0x02, :left_shift},
    {0x04, :left_alt},
    {0x08, :left_super},
    {0x10, :right_control},
    {0x20, :right_shift},
    {0x40, :right_alt},
    {0x80, :right_super}
  ]

  @type t ::
          unquote(
            Enum.reduce(
              Enum.uniq(Enum.map(@keys(), &elem(&1, 0)) ++ Enum.map(@modifiers(), &elem(&1, 0))),
              &{:|, [], [&1, &2]}
            )
          )

  @spec scancode(keycode :: AFK.Keycode.with_scancode()) :: t
  def scancode(keycode), do: __MODULE__.Protocol.scancode(keycode)

  @spec keys :: [{t, AFK.Keycode.Key.key()}]
  def keys, do: @keys

  @spec modifiers :: [{t, AFK.Keycode.Modifier.modifier()}]
  def modifiers, do: @modifiers
end
