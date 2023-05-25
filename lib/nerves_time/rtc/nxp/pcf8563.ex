defmodule NervesTime.RTC.NXP.PCF8563 do
  @moduledoc """
  datasheet: https://www.nxp.com/docs/en/data-sheet/PCF8563.pdf
  """

  @behaviour NervesTime.RealTimeClock

  alias NervesTime.RTC.NXP.PCA8565

  @impl NervesTime.RealTimeClock
  defdelegate init(args), to: PCA8565

  @impl NervesTime.RealTimeClock
  defdelegate terminate(state), to: PCA8565

  @impl NervesTime.RealTimeClock
  defdelegate set_time(state, now), to: PCA8565

  @impl NervesTime.RealTimeClock
  defdelegate get_time(state), to: PCA8565
end
