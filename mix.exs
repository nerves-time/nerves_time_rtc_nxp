# SPDX-FileCopyrightText: None
#
# SPDX-License-Identifier: CC0-1.0
defmodule NervesTime.RTC.NXP.MixProject do
  use Mix.Project

  @version "0.2.2"
  @source_url "https://github.com/nerves-time/nerves_time_rtc_nxp"

  def project do
    [
      app: :nerves_time_rtc_nxp,
      version: @version,
      elixir: "~> 1.13",
      description: description(),
      package: package(),
      source_url: @source_url,
      docs: docs(),
      dialyzer: [
        flags: [:unmatched_returns, :error_handling, :missing_return, :extra_return, :underspecs]
      ],
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def cli do
    [preferred_envs: %{docs: :docs, "hex.publish": :docs, "hex.build": :docs}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:circuits_i2c, "~> 1.0 or ~> 2.0"},
      {:nerves_time, "~> 0.4"},
      {:ex_doc, "~> 0.19", only: :docs, runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false}
    ]
  end

  def description, do: "NervesTime.RTC implementations for common NXP chips"

  def package do
    [
      files: [
        "CHANGELOG.md",
        "lib",
        "LICENSES",
        "mix.exs",
        "NOTICE",
        "README.md",
        "REUSE.toml"
      ],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "REUSE Compliance" =>
          "https://api.reuse.software/info/github.com/nerves-time/nerves_time_rtc_nxp"
      }
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
