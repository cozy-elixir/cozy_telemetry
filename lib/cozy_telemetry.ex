defmodule CozyTelemetry do
  @moduledoc """
  Provides a modular approach for using [beam-telemetry](https://github.com/beam-telemetry) packages.

  ## Quick Start

  Before running `#{__MODULE__}`, you must provide some metrics modules. For example:

      defmodule MyApp.Cache do
        use CozyTelemetry.Metrics

        @impl CozyTelemetry.Metrics
        def metrics(meta) do
          [
            summary("cache.duration",
              unit: {:native, :second},
              tags: [:type, :key]
            )
          ]
        end
      end

  Then, set some base configuration within `config/config.exs`:

      config :my_app, CozyTelemetry,
        meta: [],
        metrics: [
          MyApp.Cache
        ],
        reporter: {:console, []}

  Use the application configuration you've already set and include `#{__MODULE__}` in the list of
  supervised children:

      # lib/my_app/application.ex
      def start(_type, _args) do
        children = [
          {CozyTelemetry, Application.fetch_env!(:my_app, CozyTelemetry)}
          # ...
        ]

        Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
      end

  ### about option `:meta`

  The value of option `:meta` is a keyword list, which will be passed as the argument of callback
  `metrics/1` of `CozyTelemetry.Metrics`.

  See `CozyTelemetry.Metrics`.

  ### about option `:metrics`

  The value of option `:metrics` is a list of metrics modules.

  See `CozyTelemetry.Metrics`.

  ### about option `:optional_metrics`

  Same as option `:metrics`, but ignore errors when the given metrics module is missing.

  See `CozyTelemetry.Metrics`.

  > When using `:cozy_telemetry` as a direct dependency, this option is unnecessary.
  > But, when building a new package on `:cozy_telemetry`, this option is useful for some case, such
  > as auto loading metrics modules.

  ### about option `:reporter`

  The value of option `:reporter` specifies the reporter and its options, which is in format of
  `{type, reporter_opts}`:

  + available values of `type` are `:console`, `:statsd`, `prometheus`.
  + available values of `reporter_opts` can be found in corresponding underlying modules:
    - `Telemetry.Metrics.ConsoleReporter`
    - [`TelemetryMetricsStatsd`](https://hexdocs.pm/telemetry_metrics_statsd)
    - [`TelemetryMetricsPrometheus`](https://hexdocs.pm/telemetry_metrics_prometheus)

  """

  alias __MODULE__.Metrics

  @builtin_reporters %{
    console: __MODULE__.Reporters.Console,
    statsd: __MODULE__.Reporters.Statsd,
    prometheus: __MODULE__.Reporters.Prometheus
  }

  @builtin_reporter_types Map.keys(@builtin_reporters)

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
