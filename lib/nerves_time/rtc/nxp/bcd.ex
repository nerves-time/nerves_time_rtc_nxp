defmodule NervesTime.RTC.NXP.BCD do
  @moduledoc """
  Helpers for converting to and from register values
  """

  @doc "Convert a 8 bit integer value to a BCD binary"
  def int_to_bcd(value) when value <= 9 do
    <<0::integer-4, value::integer-4>>
  end

  def int_to_bcd(value) when value <= 99 do
    tens = div(value, 10)
    units = rem(value, 10)
    <<tens::integer-4, units::integer-4>>
  end

  @doc "Convert a 8 bit bcd bitstring to an integer"
  def bcd_to_int(value, power \\ 10)

  # 5 bit bcd
  def bcd_to_int(<<tens::integer-1, units::integer-4>>, pow),
    do: bcd_to_int(tens, units, pow)

  # 6 bit bcd
  def bcd_to_int(<<tens::integer-2, units::integer-4>>, pow),
    do: bcd_to_int(tens, units, pow)

  # 7 bit bcd
  def bcd_to_int(<<tens::integer-3, units::integer-4>>, pow),
    do: bcd_to_int(tens, units, pow)

  # 8 bit bcd
  def bcd_to_int(<<tens::integer-4, units::integer-4>>, pow),
    do: bcd_to_int(tens, units, pow)

  defp bcd_to_int(tens, units, pow) when units >= pow,
    do: bcd_to_int(tens, units, pow * 10)

  defp bcd_to_int(tens, units, pow),
    do: tens * pow + units
end
