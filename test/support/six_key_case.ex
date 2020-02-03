defmodule AFK.SixKeyCase do
  @moduledoc false

  use ExUnit.CaseTemplate
  use Bitwise

  alias AFK.HIDReport.SixKeyRollover
  alias AFK.Keycode.{Key, Modifier}
  alias AFK.State

  import AFK.Scancode, only: [scancode: 1]

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
    %{state: state}
  end

  # TODO: spec
  def assert_hid_reports(reports, timeout \\ 100) do
    limit = :os.system_time(:millisecond) + timeout

    expected_reports =
      Enum.map(reports, fn report ->
        keys = Keyword.get(report, :keys, [0, 0, 0, 0, 0, 0])
        mods = Keyword.get(report, :mods, [])

        [one, two, three, four, five, six] =
          Enum.map(keys, fn
            0 -> 0
            %Key{} = keycode -> scancode(keycode)
          end)

        modifier_byte = Enum.reduce(mods, 0, fn %Modifier{} = keycode, acc -> scancode(keycode) ||| acc end)

        <<modifier_byte, 0, one, two, three, four, five, six>>
      end)

    do_assert_reports([<<0, 0, 0, 0, 0, 0, 0, 0>> | expected_reports], limit)
  end

  defp do_assert_reports(expected_reports, limit) do
    {:messages, messages} = :erlang.process_info(self(), :messages)
    received_reports = Enum.map(messages, fn {:hid_report, report} -> report end)

    cond do
      expected_reports == received_reports ->
        assert expected_reports == received_reports

      :os.system_time(:millisecond) + 10 >= limit ->
        assert expected_reports == received_reports

      true ->
        Process.sleep(10)
        do_assert_reports(expected_reports, limit)
    end
  end
end
