# SPDX-FileCopyrightText: 2020 Connor Rigby
# SPDX-FileCopyrightText: 2020 Frank Hunleth
# SPDX-FileCopyrightText: 2023 Jon Carstens
# SPDX-FileCopyrightText: 2023 Ryota Kinukawa
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule NervesTime.RTC.NXP.PCA8565 do
  @moduledoc """
  datasheet: https://www.nxp.com/docs/en/data-sheet/PCA8565.pdf
  """

  @behaviour NervesTime.RealTimeClock
  import NervesTime.RealTimeClock.BCD

  alias Circuits.I2C

  @default_bus_name "i2c-1"
  @default_address 0x51

  @register_control <<0x00>>

  @register_seconds <<0x02>>
  # @register_minutes <<0x03>>
  # @register_hours <<0x04>>
  # @register_days <<0x05>>
  # @register_weekdays <<0x06>>
  # @register_months <<0x07>>
  # @register_years <<0x08>>

  @type address :: pos_integer()

  @type state :: %{
          i2c: I2C.Bus.t(),
          bus_name: String.t(),
          address: address()
        }

  @doc false
  @impl NervesTime.RealTimeClock
  def init(args) do
    bus_name = Keyword.get(args, :bus_name, @default_bus_name)
    address = Keyword.get(args, :address, @default_address)

    with {:ok, i2c} <- I2C.open(bus_name),
         true <- rtc_available?(i2c, address) do
      {:ok, %{i2c: i2c, bus_name: bus_name, address: address}}
    else
      {:error, _} = error ->
        error

      error ->
        {:error, error}
    end
  end

  @impl NervesTime.RealTimeClock
  def terminate(_state), do: :ok

  @impl NervesTime.RealTimeClock
  def set_time(state, now) do
    _ = set_time_to_rtc(state, now)
    state
  end

  @impl NervesTime.RealTimeClock
  def get_time(state) do
    with {:ok, time} <- get_time_from_rtc(state) do
      {:ok, time, state}
    else
      _ -> {:unset, state}
    end
  end

  @spec set_time_to_rtc(state, NaiveDateTime.t()) :: :ok | {:error, term()}
  defp set_time_to_rtc(state, %NaiveDateTime{} = date_time) do
    I2C.write(state.i2c, state.address, [
      @register_seconds,
      time_to_registers(date_time)
    ])
  end

  @spec get_time_from_rtc(state) :: {:ok, NaiveDateTime.t()} | {:error, term()}
  defp get_time_from_rtc(state) do
    with {:ok, registers} <-
           I2C.write_read(state.i2c, state.address, @register_seconds, 7) do
      {:ok, registers_to_time(registers)}
    end
  end

  @spec rtc_available?(I2C.Bus.t(), address) :: boolean()
  defp rtc_available?(i2c, address) do
    case I2C.write_read(i2c, address, @register_control, 1) do
      {:ok, ok} when byte_size(ok) == 1 ->
        true

      {:error, :i2c_nak} ->
        false
    end
  end

  defp time_to_registers(%NaiveDateTime{} = date_time) do
    second_bcd = from_integer(date_time.second)
    minute_bcd = from_integer(date_time.minute)
    hour_bcd = from_integer(date_time.hour)
    day_bcd = from_integer(date_time.day)

    weekday_bcd =
      Calendar.ISO.day_of_week(date_time.year, date_time.month, date_time.day, :sunday)
      |> then(fn {day_of_week, 1, 7} -> day_of_week - 1 end)
      |> from_integer()

    month_bcd = from_integer(date_time.month)
    year_bcd = from_integer(date_time.year - 2000)

    <<
      # unset the VL bit. The clock is guaranteed after this.
      0::integer-1,
      second_bcd::integer-7,
      # drop first bit
      0::integer-1,
      minute_bcd::integer-7,
      # drop first two bits
      0::integer-2,
      hour_bcd::integer-6,
      0::integer-2,
      day_bcd::integer-6,
      # drop first five bits
      0::integer-5,
      weekday_bcd::integer-3,
      # first bit is century. drop 2 bits.
      1::integer-1,
      0::integer-2,
      month_bcd::integer-5,
      year_bcd
    >>
  end

  defp registers_to_time(
         <<_vl::integer-1, second_bcd::integer-7, _::integer-1, minute_bcd::integer-7,
           _::integer-2, hour_bcd::integer-6, _::integer-2, day_bcd::integer-6, _::integer-5,
           _weekday_bcd::integer-3, _c::integer-1, _::integer-2, month_bcd::integer-5,
           year_bcd::integer-8>>
       ) do
    %NaiveDateTime{
      day: to_integer(day_bcd),
      hour: to_integer(hour_bcd),
      minute: to_integer(minute_bcd),
      month: to_integer(month_bcd),
      second: to_integer(second_bcd),
      year: 2000 + to_integer(year_bcd)
    }
  end
end
