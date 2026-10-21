# SPDX-FileCopyrightText: 2026 Bryan Leong
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule NervesTime.RTC.NXP.FakeBus do
  defstruct [:registers]

  defimpl Circuits.I2C.Bus do
    def flags(_bus), do: []
    def read(_bus, _address, _count, _options), do: {:error, :unsupported}
    def write(_bus, _address, _data, _options), do: :ok

    def write_read(bus, 0x51, <<0x02>>, 7, _options), do: {:ok, bus.registers}

    def close(_bus), do: :ok
  end
end
