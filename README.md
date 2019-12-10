# AFK

A library for modeling the internal state of a computer keyboard. It supports
arbitrary layouts with any number of layers, and outputs a basic 6-key HID
report byte string.

Its intended use is to model the state for keyboard firmware. A work-in-progress
firmware using Nerves is being attempted [over
here](https://github.com/doughsay/keyboard).

## Installation

AFK can be installed by adding `afk` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:afk, "~> 0.1.0"}
  ]
end
```

## Basic Usage

First, you define a keymap:

```elixir
keymap = [
  # Layer 0 (default)
  %{
    k001: AFK.Keycode.Key.new(:a),
    k002: AFK.Keycode.Modifier.new(:left_control),
    k003: AFK.Keycode.Layer.new(:hold, 1),
    k004: AFK.Keycode.Key.new(:caps_lock)
  },
  # Layer 1
  %{
    k001: AFK.Keycode.Key.new(:z),
    k002: AFK.Keycode.Modifier.new(:right_super),
    k003: AFK.Keycode.None.new(),
    k004: AFK.Keycode.Transparent.new()
  }
]
```

You can now initialize an `AFK.State` struct and press and release keys. Calling
`to_hid_report/1` returns a byte string for sending to a HID interface
configured as a basic 6-key rollover USB keyboard.

```elixir
state = AFK.State.new(keymap)

state =
  state
  |> AFK.State.press_key(:k003)
  |> AFK.State.press_key(:k002)
  |> AFK.State.press_key(:k001)

AFK.State.to_hid_report(state)
# => <<128, 0, 29, 0, 0, 0, 0, 0>>

state = AFK.State.release_key(state, :k002)

AFK.State.to_hid_report(state)
# => <<0, 0, 29, 0, 0, 0, 0, 0>>
```

## Future Features

It's intended to eventually support N-key rollover, but for now it just supports
basic 6-key rollover.

It may eventually also support more complex interactions, such as sticky keys,
macros, leader keys, etc. These features require a lot more thinking though, as
they will require a process that emits an event stream as opposed to the current
data structure approach.

## Docs

Documentation can be found at [https://hexdocs.pm/afk](https://hexdocs.pm/afk).
