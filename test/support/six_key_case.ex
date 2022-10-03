defmodule AFK.SixKeyCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  import AFK.Scancode, only: [scancode: 1]
  import Bitwise

  alias AFK.HIDReport.SixKeyRollover
  alias AFK.Keycode.Key
  alias AFK.Keycode.Modifier
  alias AFK.State

  using do
    quote do
      import AFK.SixKeyCase
    end
  end

  setup context do
    args = [
      event_receiver: self(),
      keymap: context[:keymap],
      hid_report_mod: SixKeyRollover
    ]

    {:ok, state} = State.start_link(args)

    # assert the initial "clean state" report is sent
    assert_hid_report %{}

    %{state: state}
  end

  @type key :: 0 | AFK.Keycode.Key.t()
  @type keys :: {key, key, key, key, key, key}
  @type mods :: [AFK.Keycode.Modifier.t()]
  @type report :: %{optional(:keys) => keys, optional(:mods) => mods}

  @spec assert_hid_report(report :: report, timeout :: non_neg_integer) :: true
  def assert_hid_report(report, timeout \\ 10) do
    assert_hid_reports [report], timeout
  end

  @spec assert_hid_reports(reports :: [report], timeout :: non_neg_integer) :: true
  def assert_hid_reports(reports, timeout \\ 10) do
    expected_reports =
      Enum.map(reports, fn report ->
        keys = Map.get(report, :keys, {0, 0, 0, 0, 0, 0})
        mods = Map.get(report, :mods, [])

        [one, two, three, four, five, six] =
          keys
          |> Tuple.to_list()
          |> Enum.map(fn
            0 -> 0
            %Key{} = keycode -> scancode(keycode)
          end)

        modifier_byte = Enum.reduce(mods, 0, fn %Modifier{} = keycode, acc -> scancode(keycode) ||| acc end)

        <<modifier_byte, 0, one, two, three, four, five, six>>
      end)

    for expected_report <- expected_reports do
      assert_receive {:hid_report, ^expected_report}, timeout
    end
  end

  # Asserts that no hid reports are being received within timeout
  @spec refute_hid_reports(timeout :: non_neg_integer) :: true
  def refute_hid_reports(timeout \\ 10) do
    refute_receive {:hid_report, _}, timeout
  end
end
