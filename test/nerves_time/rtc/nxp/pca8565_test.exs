# SPDX-FileCopyrightText: 2026 Bryan Leong
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule NervesTime.RTC.NXP.PCA8565Test do
  use ExUnit.Case, async: true

  alias NervesTime.RTC.NXP.PCA8565

  defp state(registers) do
    %{i2c: %NervesTime.RTC.NXP.FakeBus{registers: registers}, bus_name: "i2c-1", address: 0x51}
  end

  test "returns the time when the registers hold a valid date and time" do
    state = state(<<0x30, 0x45, 0x13, 0x29, 0x04, 0x82, 0x24>>)

    assert PCA8565.get_time(state) == {:ok, ~N[2024-02-29 13:45:30], state}
  end

  test "returns unset when the VL bit is set" do
    state = state(<<0xB0, 0x45, 0x13, 0x29, 0x04, 0x82, 0x24>>)

    assert PCA8565.get_time(state) == {:unset, state}
  end

  test "returns unset when the month is 0" do
    state = state(<<0x41, 0x34, 0x04, 0x12, 0x00, 0x00, 0x30>>)

    assert PCA8565.get_time(state) == {:unset, state}
  end
end
