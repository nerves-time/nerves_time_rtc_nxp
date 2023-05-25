# NervesTime.RTC.NXP

NervesTime.RTC implementations for common NXP chips

## Currently supported modules

|model|datasheet|elixir module|
|:---:|---------|-------------|
| PCA8565 | https://www.nxp.com/docs/en/data-sheet/PCA8565.pdf | `NervesTime.RTC.NXP.PCA8565` |
| PCF8563 | https://www.nxp.com/docs/en/data-sheet/PCF8563.pdf | `NervesTime.RTC.NXP.PCF8563` |

## Using

First add this project to your `mix` dependencies:

```elixir
def deps do
  [
    {:nerves_time_rtc_nxp, "~> 0.1.0"}
  ]
end
```

And then update your `:nerves_time` configuration to point to it:

```elixir
config :nerves_time, rtc: NervesTime.RTC.NXP.PCA8565
```

It's possible to override the default I2C bus and address via options:

```elixir
config :nerves_time, rtc: {NervesTime.RTC.NXP.PCA8565, [bus_name: "i2c-2", address:
0x51]}
```

Check the logs for error messages if the RTC doesn't appear to work.

