# AFK

A library for modeling the internal state of a computer afk. It supports
arbitrary layouts with any number of layers, and outputs a basic 6-key HID
report byte string.

It's intended use is to model the state for keyboard firmware. A
work-in-progress firmware using Nerves is being attempted [over
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

Documentation can be found at [https://hexdocs.pm/afk](https://hexdocs.pm/afk).
