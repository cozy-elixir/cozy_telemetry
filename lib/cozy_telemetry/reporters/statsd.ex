defmodule CozyTelemetry.Reporters.Statsd do
  @moduledoc false

  @behaviour CozyTelemetry.Reporter

  @reporter_module TelemetryMetricsStatsd

  if Code.ensure_loaded?(@reporter_module) do
    @impl true
    def check_deps(), do: :ok

    @impl true
    def child_spec(init_arg) do
      @reporter_module.child_spec(init_arg)
    end
  else
    @reporter_package :telemetry_metrics_statsd

    @impl true
    def check_deps() do
      CozyTelemetry.Reporter.print_missing_package(@reporter_package)
      raise "missing dependency - #{inspect(@reporter_package)}"
    end

    @impl true
    def child_spec(_init_arg) do
      raise "missing dependency - #{inspect(@reporter_package)}"
    end
  end
end
