defmodule NervesTime.RTC.NXP.BCDTest do
  use ExUnit.Case
  use PropCheck
  alias NervesTime.RTC.NXP.BCD

  property "conversion is symmetrical" do
    forall int <- integer(0, 99) do
      bcd = BCD.int_to_bcd(int)
      assert BCD.bcd_to_int(bcd) == int
      assert match?(<<_::8>>, bcd)
    end
  end
end
