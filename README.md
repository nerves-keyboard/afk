# AFK

[![CI Status](https://github.com/doughsay/afk/workflows/CI/badge.svg)](https://github.com/doughsay/afk/actions)
[![codecov](https://codecov.io/gh/doughsay/afk/branch/master/graph/badge.svg)](https://codecov.io/gh/doughsay/afk)
[![SourceLevel](https://app.sourcelevel.io/github/doughsay/afk.svg)](https://app.sourcelevel.io/github/doughsay/afk)
[![Hex.pm Version](https://img.shields.io/hexpm/v/afk.svg?style=flat)](https://hex.pm/packages/afk)
[![License](https://img.shields.io/hexpm/l/afk.svg)](LICENSE.md)

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

You can now start a state process using `AFK.State.start_link/2`, by providing a
keymap, an event receiver PID, and a module that implements the `AFK.HIDReport`
behaviour.

```elixir
{:ok, state} =
  AFK.State.start_link(
    keymap: keymap,
    event_receiver: self(),
    hid_report_mod: AFK.HIDReport.SixKeyRollover
  )

AFK.State.press_key(state, :k003)
AFK.State.press_key(state, :k002)
AFK.State.press_key(state, :k001)
AFK.State.release_key(state, :k002)

# take a look at our process mailbox
:erlang.process_info(self(), :messages)

# {:messages,
#  [
#    hid_report: <<0, 0, 0, 0, 0, 0, 0, 0>>,
#    hid_report: <<128, 0, 0, 0, 0, 0, 0, 0>>,
#    hid_report: <<128, 0, 29, 0, 0, 0, 0, 0>>,
#    hid_report: <<0, 0, 29, 0, 0, 0, 0, 0>>
#  ]}
```

## Future Features

AFK provides a behaviour for defining how to convert the state into a HID
report. Currently only a 6-key rollover implementation is provided, but an N-key
rollover implementation would be a great addition. (Pull requests welcome!)

It may eventually also support more complex interactions, such as sticky keys,
macros, leader keys, etc. These features require a lot more thinking though, as
they will require the state undergoing changes over time.

## Docs

Documentation can be found at [https://hexdocs.pm/afk](https://hexdocs.pm/afk).
