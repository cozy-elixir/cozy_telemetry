defmodule CozyTelemetry do
  @moduledoc """
  Provides a modular approach for using [beam-telemetry](https://github.com/beam-telemetry) packages.

  ## Quick Start

  Before running `CozyTelemetry`, you must provide some modules. For example:

      defmodule MyApp.Cache.TelemetrySpec do
        use CozyTelemetry.Spec

        @impl true
        def metrics(_meta) do
          [
            summary("cache.duration",
              unit: {:native, :second},
              tags: [:type, :key]
            ),

            last_value("cache.stats.hits",
              event_name: "cache.stats",
              measurement: :hits,
              tags: [:cache]
            )
          ]
        end

        @impl true
        def measurements(meta) do
          [
            {__MODULE__, :dispatch_stats, []}
          ]
        end
      end

  Then, set some base configuration within `config/config.exs`:

      config :my_app, CozyTelemetry,
        meta: [],
        specs: [
          MyApp.Cache.TelemetrySpec
        ],
        reporter: {:console, []},
        poller: [period: 10_000]

  Use the application configuration you've already set and include `CozyTelemetry.*` in the list of
  supervised children:

      # lib/my_app/application.ex
      def start(_type, _args) do
        cozy_telemetry_config = Application.fetch_env!(:my_app, CozyTelemetry)

        children = [
          {CozyTelemetry.Reporter, cozy_telemetry_config},
          {CozyTelemetry.Poller, cozy_telemetry_config},
          # ...
        ]

        Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
      end

  ### about option `:meta`

  The value of option `:meta` is a keyword list, which will be passed as the argument of:

  + callback `metrics/1` of `CozyTelemetry.Spec`.
  + callback `measurements/1` of `CozyTelemetry.Spec`.

  See `CozyTelemetry.Spec` for more details.

  ### about option `:specs`

  The value of option `:specs` is a list of spec modules.

  See `CozyTelemetry.Spec` for more details.

  ### about option `:optional_specs`

  Same as option `:specs`, but ignore errors when the given spec module is missing.

  > When using `:cozy_telemetry` as a direct dependency, this option is unnecessary.
  > But, when building a new package on `:cozy_telemetry`, this option is useful for some case,
  > such as auto loading measurements modules.

  ### about option `:reporter`

  The value of option `:reporter` specifies the reporter and its options, which is in format of
  `{type, reporter_opts}`:

  + available values of `type` are `:console`, `:statsd`, `prometheus`.
  + available values of `reporter_opts` can be found in corresponding underlying modules:
    - `Telemetry.Metrics.ConsoleReporter`
    - [`TelemetryMetricsStatsd`](https://hexdocs.pm/telemetry_metrics_statsd)
    - [`TelemetryMetricsPrometheus`](https://hexdocs.pm/telemetry_metrics_prometheus)

  ### about option `:poller`

  The value of option `:poller` is the options of `:telemetry_poller.start_link/1`.

  """

  defdelegate load_metrics(opts), to: CozyTelemetry.Spec
  defdelegate load_measurements(opts), to: CozyTelemetry.Spec
end
