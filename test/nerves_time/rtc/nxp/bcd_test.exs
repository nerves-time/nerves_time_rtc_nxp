defmodule NervesTime.RTC.NXP.BCDTest do
  use ExUnit.Case
  alias NervesTime.RTC.NXP.BCD

  test "all values convert" do
    for tens <- 0..9, ones <- 0..9 do
      number = tens * 10 + ones
      bcd = tens * 16 + ones

      assert BCD.int_to_bcd(number) == bcd
      assert BCD.bcd_to_int(bcd) == number
    end
  end
end
