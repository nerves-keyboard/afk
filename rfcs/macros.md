# macros

- macros are sequences of `AFK.Keycode`s, not sequences of physical key events
- macros can have either an on-press or an on-release sequence or both
- macro sequences need some (possibly configurable) delay between keycodes
- when a macro sequence plays, it ignores the state of the keyboard; it instead
  sends an "all clear" HID report (effectively releasing all keys), plays the
  sequence, then restores the state of the keyboard and sends an updated HID
  report representing the current state
  - the state may have changed during the playing of the sequence (it just
    doesn't send HID reports during the sequence)

## examples

### a macro that types "Hello, World!"

```elixir
Macro.new(
  on_press:
    [
      {:down, Modifier.new(:left_shift)},
      {:tap, Key.new(:h)},
      {:up, Modifier.new(:left_shift)},
      {:tap, Key.new(:e)},
      {:tap, Key.new(:l)},
      {:tap, Key.new(:l)},
      {:tap, Key.new(:o)},
      {:tap, Key.new(:comma)},
      {:tap, Key.new(:space)},
      {:delay, 1_000}, # optional extra delay in addition to default delay
      {:down, Modifier.new(:left_shift)},
      {:tap, Key.new(:w)},
      {:up, Modifier.new(:left_shift)},
      {:tap, Key.new(:o)},
      {:tap, Key.new(:r)},
      {:tap, Key.new(:l)},
      {:tap, Key.new(:d)},
      {:down, Modifier.new(:left_shift)},
      {:tap, Key.new(:"1")},
      {:up, Modifier.new(:left_shift)}
    ],
  on_release: [],
  delay: 25 # default delay, milliseconds
)
```

### single-key copy-paste

```elixir
Macro.new(
  on_press:
    [
      {:down, Modifier.new(:left_control)},
      {:tap, Key.new(:c)},
      {:up, Modifier.new(:left_control)}
    ],
  on_release:
    [
      {:down, Modifier.new(:left_control)},
      {:tap, Key.new(:v)},
      {:up, Modifier.new(:left_control)}
    ]
)
```

## open questions/gotchas

- macros need to be validated/sanitized before they can be used:
  - a macro must release all keys it presses (i.e. there must be an `:up` for
    every `:down`)
  - some keycodes don't make sense to support in macros (layer switching,
    none/transparent). what about tap keys? key lock? do we limit to just keys
    with scancodes?
  - macros in macros? why? composability/reusability maybe?
- sending the keycode for "a" only causes an "a" to appear in the OS if the OS
  is using a standard qwerty layout. If the OS itself has a modified (software)
  keymap, then macros need to be adjusted accordingly.

## things QMK can do that the above could not do

- super alt-tab: a key that when tapped, sends ALT+TAB, and keeps ALT held for
  up to a 1-second timeout. During the timeout, tapping the key again sends TAB
  again and resets the timeout. Waiting for the timeout then releases ALT.
  - this sounds possible to do using "tap keys" if we make that feature
    sufficiently powerful. maybe...
