defmodule NervesTime.RTC.NXP.BCD do
  @moduledoc """
  Helpers for converting to and from binary coded decimal (BCD)

  BCD is commonly used in Real-time clock chips for historical reasons. See
  [wikipedia.org/wiki/Binary-coded_decimal](https://en.wikipedia.org/wiki/Binary-coded_decimal)
  for a good background on BCD. The BCD implementation here is referred to as
  "Packed BCD" in the article.
  """

  @doc "Convert a 8 bit integer value to a BCD binary"
  @spec int_to_bcd(0..99) :: 0..0x99
  def int_to_bcd(value) when value <= 9 do
    value
  end

  def int_to_bcd(value) when value <= 99 do
    tens = div(value, 10)
    units = rem(value, 10)
    16 * tens + units
  end

  @doc "Convert a 8 bit bcd-encoded value to an integer"
  @spec bcd_to_int(0..0x99) :: 0..99
  def bcd_to_int(value) when value <= 9 do
    value
  end

  def bcd_to_int(value) do
    tens = div(value, 16)
    units = rem(value, 16)
    10 * tens + units
  end
end
