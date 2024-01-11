defmodule CozyTelemetry.Reporters.Console do
  @moduledoc false

  @behaviour CozyTelemetry.Reporter

  @reporter_module Telemetry.Metrics.ConsoleReporter

  @impl true
  def check_deps() do
    :ok
  end

  @impl true
  def child_spec(init_arg) do
    @reporter_module.child_spec(init_arg)
  end
end
