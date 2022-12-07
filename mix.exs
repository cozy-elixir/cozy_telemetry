defmodule CozyTelemetry.MixProject do
  use Mix.Project

  def project do
    [
      app: :cozy_telemetry,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:telemetry, "~> 1.0"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_metrics_statsd, "~> 0.6", only: :test}
    ]
  end
end
