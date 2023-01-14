defmodule CozyTelemetry.Reporter do
  @moduledoc """
  The application which reports metrics.

  This module also defines a behaviour for declaring reporters.
  """

  @type init_arg :: keyword()

  @type child_spec() :: %{
          id: term(),
          start: term(),
          type: term()
        }

  @doc """
  Checks required dependencies.

  When dependencies are missing, an exception should be raised.
  """
  @callback check_deps() :: :ok

  @doc """
  Generates child specification for starting a reporter.
  """
  @callback child_spec(init_arg) :: child_spec()

  require Logger

  @doc """
  Prints consistent error messages of missing package for reporters.
  """
  def print_missing_package(package_name) do
    Logger.error("""
    Could not find #{inspect(package_name)} dependency.

    Please add #{inspect(package_name)} to your dependencies:

        {#{inspect(package_name)}, version}

    """)
  end

  alias CozyTelemetry.Metrics

  @builtin_reporters %{
    console: CozyTelemetry.Reporters.Console,
    statsd: CozyTelemetry.Reporters.Statsd,
    prometheus: CozyTelemetry.Reporters.Prometheus
  }

  @builtin_reporter_types Map.keys(@builtin_reporters)

  @doc """
  Builds a child specifications.
  """
  def child_spec(init_arg) do
    meta = Keyword.get(init_arg, :meta, [])
    metrics_modules = Keyword.get(init_arg, :metrics, [])
    optional_metrics_modules = Keyword.get(init_arg, :optional_metrics, [])

    metrics = load_metrics(metrics_modules, optional_metrics_modules, meta)

    init_arg
    |> Keyword.fetch!(:reporter)
    |> normalize_reporter()
    |> check_reporter_deps()
    |> generate_child_spec(metrics)
  end

  defp load_metrics(modules, optional_modules, meta)
       when is_list(modules) and is_list(optional_modules) do
    metrics =
      Enum.reduce(modules, [], fn module, metrics ->
        metrics ++ Metrics.load_metrics_from_module!(module, meta)
      end)

    optional_metrics =
      Enum.reduce(optional_modules, [], fn module, metrics ->
        metrics ++ Metrics.load_metrics_from_module(module, meta)
      end)

    metrics ++ optional_metrics
  end

  defp normalize_reporter({type, opts}) when type in @builtin_reporter_types do
    reporter = Map.fetch!(@builtin_reporters, type)
    {reporter, opts}
  end

  defp normalize_reporter(reporter) do
    raise ArgumentError, "bad option :reporter - #{inspect(reporter)}"
  end

  defp check_reporter_deps({reporter, opts}) do
    :ok = reporter.check_deps()
    {reporter, opts}
  end

  defp generate_child_spec({reporter, opts}, metrics) do
    opts = Keyword.put(opts, :metrics, metrics)
    reporter.child_spec(opts)
  end
end
