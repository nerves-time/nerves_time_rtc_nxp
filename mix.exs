defmodule NervesTime.RTC.NXP.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/nerves-time/nerves_time_rtc_nxp"

  def project do
    [
      app: :nerves_time_rtc_nxp,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: @source_url,
      docs: docs(),
      dialyzer: [
        flags: [:unmatched_returns, :error_handling, :race_conditions, :underspecs]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:circuits_i2c, "~> 0.3.6"},
      {:nerves_time, "~> 0.4.0"},
      {:ex_doc, "~> 0.19", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false}
    ]
  end

  def description, do: "NervesTime.RTC implementations for common NXP chips"

  def package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  def docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
