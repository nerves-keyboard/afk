defmodule AFK.HIDReport do
  @moduledoc """
  Defines a behaviour for converting an `AFK.State` struct into a binary USB HID
  report.

  Current implementations:

  * `AFK.HIDReport.SixKeyRollover
  """

  @callback hid_report(AFK.State.t()) :: binary()
end
