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
  @register_minutes <<0x3>>
  @register_hours <<0x04>>
  @register_days <<0x05>>
  # @register_weekday <<0x06>>
  @register_months <<0x07>>
  @register_year <<0x08>>

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
    # discard top bit
    <<_::bits-1, second::integer-7>> = int_to_bcd(date_time.second)
    # discard top bit
    <<_::bits-1, minute::integer-7>> = int_to_bcd(date_time.minute)
    # discard 2 bits
    <<_::bits-2, hour::integer-6>> = int_to_bcd(date_time.hour)
    <<_::bits-2, day::integer-6>> = int_to_bcd(date_time.day)
    <<_::bits-3, month::integer-5>> = int_to_bcd(date_time.month)
    year = int_to_bcd(date_time.year - 2000)

    I2C.write(state.i2c, state.address, [
      @register_seconds,
      # unset the VL bit. The clock is guaranteed after this.
      <<0::integer-1, second::integer-7>>,
      # drop first bit
      <<0::integer-1, minute::integer-7>>,
      # drop first two bits
      <<0::integer-2, hour::integer-6>>,
      <<0::integer-2, day::integer-6>>,
      # TODO(connor) weekday
      <<0::size(8)>>,
      # first bit is century. drop 2 bits.
      <<1::integer-1, 0::integer-2, month::integer-5>>,
      year
    ])
  end

  @spec get_time_from_rtc(state) :: {:ok, NaiveDateTime.t()} | {:error, term()}
  defp get_time_from_rtc(state) do
    with {:ok, <<_vl::bits-1, second::bits-7>>} <-
           I2C.write_read(state.i2c, state.address, @register_seconds, 1),
         {:ok, <<_::bits-1, minute::bits-7>>} <-
           I2C.write_read(state.i2c, state.address, @register_minutes, 1),
         {:ok, <<_::bits-2, hour::bits-6>>} <-
           I2C.write_read(state.i2c, state.address, @register_hours, 1),
         {:ok, <<_::bits-2, day::bits-6>>} <-
           I2C.write_read(state.i2c, state.address, @register_days, 1),
         {:ok, <<_c::bits-1, _::bits-2, month::bits-5>>} <-
           I2C.write_read(state.i2c, state.address, @register_months, 1),
         # implied 20XX
         {:ok, <<year::bits-8>>} <- I2C.write_read(state.i2c, state.address, @register_year, 1) do
      dt = %NaiveDateTime{
        day: bcd_to_int(day),
        hour: bcd_to_int(hour),
        minute: bcd_to_int(minute),
        month: bcd_to_int(month),
        second: bcd_to_int(second),
        year: 2000 + bcd_to_int(year)
      }

      {:ok, dt}
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
end
