defmodule NervesTime.RTC.NXP.PCA8565 do
  @moduledoc """
  datasheet: https://www.nxp.com/docs/en/data-sheet/PCA8565.pdf
  """

  @behaviour NervesTime.RealTimeClock
  import NervesTime.RTC.NXP.BCD

  require Logger
  alias Circuits.I2C

  @default_bus_name "i2c-1"
  @default_address 0x51

  @register_control <<0x00>>

  @register_seconds <<0x2>>
  # @register_minutes <<0x3>>
  # @register_hours <<0x04>>
  # @register_days <<0x05>>
  # @register_weekday <<0x06>>
  # @register_months <<0x07>>
  # @register_year <<0x08>>

  @type address :: pos_integer()

  @type state :: %{
          i2c: I2C.bus(),
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
  def update(state) do
    set_time_to_rtc(state, NaiveDateTime.utc_now())
  end

  @impl NervesTime.RealTimeClock
  def time(state) do
    get_time_from_rtc(state)
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

  @spec rtc_available?(I2C.bus(), address) :: boolean()
  defp rtc_available?(i2c, address) do
    case I2C.write_read(i2c, address, @register_control, 1) do
      {:ok, ok} when byte_size(ok) == 1 ->
        true

      {:error, :i2c_nak} ->
        false
    end
  end

  defp time_to_registers(%NaiveDateTime{} = date_time) do
    second_bcd = int_to_bcd(date_time.second)
    minute_bcd = int_to_bcd(date_time.minute)
    hour_bcd = int_to_bcd(date_time.hour)
    day_bcd = int_to_bcd(date_time.day)
    month_bcd = int_to_bcd(date_time.month)
    year_bcd = int_to_bcd(date_time.year - 2000)

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
      # TODO(connor) weekday
      0::integer-8,
      # first bit is century. drop 2 bits.
      1::integer-1,
      0::integer-2,
      month_bcd::integer-5,
      year_bcd
    >>
  end

  defp registers_to_time(
         <<_vl::integer-1, second_bcd::integer-7, _::integer-1, minute_bcd::integer-7,
           _::integer-2, hour_bcd::integer-6, _::integer-2, day_bcd::integer-6,
           _weekday_bcd::integer-8, _c::integer-1, _::integer-2, month_bcd::integer-5,
           year_bcd::integer-8>>
       ) do
    %NaiveDateTime{
      day: bcd_to_int(day_bcd),
      hour: bcd_to_int(hour_bcd),
      minute: bcd_to_int(minute_bcd),
      month: bcd_to_int(month_bcd),
      second: bcd_to_int(second_bcd),
      year: 2000 + bcd_to_int(year_bcd)
    }
  end
end
