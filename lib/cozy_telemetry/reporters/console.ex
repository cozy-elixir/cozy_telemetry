defmodule CozyTelemetry.Reporters.Console do
  @behaviour CozyTelemetry.Reporter

  @reporter_module Telemetry.Metrics.ConsoleReporter

  @moduledoc """
  A wrapper of `#{@reporter_module}`.
  """

  @impl true
  def check_deps() do
    :ok
  end

  @impl true
  def child_spec(init_arg) do
    @reporter_module.child_spec(init_arg)
  end
end
