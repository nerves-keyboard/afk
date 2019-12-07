defmodule Keyboard.Keycodes.LayerTest do
  use ExUnit.Case

  alias Keyboard.Keycodes.Layer

  doctest Layer, import: true

  test "raises if invalid layer activation type given" do
    assert_raise FunctionClauseError, fn ->
      Layer.new(:fake, 1)
    end
  end
end
