defmodule CozyTelemetry.Spec do
  @moduledoc """
  A behaviour for declaring spec.

  Any module that wants to exposing metrics or periodic measurements should
  implement this behaviour.

      defmodule MyApp.Cache.TelemetrySpec do
        use CozyTelemetry.Spec

        @impl true
        def metrics(meta) do
          [
            summary("cache.duration",
              unit: {:native, :second},
              tags: [:type, :key]
            ),
            # ...
          ]
        end

        @impl true
        def measurements(meta) do
          [
            {__MODULE__, :dispatch_stats, []},
            # ...
          ]
        end
      end

  Then, the declared metrics in above module can be loaded with following configuration:

      config :my_app, CozyTelemetry,
        meta: [],
        specs: [
          MyApp.Cache.TelemetrySpec
        ],
        # ...

  """

  require Logger

  @type meta() :: keyword()

  @doc "Declares metrics."
  @callback metrics(meta()) :: [Telemetry.Metrics.t()]

  @doc "Declares measurements."
  @callback measurements(meta()) :: [:telemetry_poller.measurement()]

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Telemetry.Metrics

      @behaviour unquote(__MODULE__)

      def metrics(_meta), do: []
      defoverridable metrics: 1

      def measurements(_meta), do: []
      defoverridable measurements: 1
    end
  end

  @doc """
  Load metrics.
  """
  def load_metrics(opts) when is_list(opts) do
    meta = Keyword.get(opts, :meta, [])
    modules = Keyword.get(opts, :specs, [])
    optional_modules = Keyword.get(opts, :optional_specs, [])

    metrics =
      Enum.reduce(modules, [], fn module, metrics ->
        metrics ++ load_metrics_from_module!(module, meta)
      end)

    optional_metrics =
      Enum.reduce(optional_modules, [], fn module, metrics ->
        metrics ++ load_metrics_from_module(module, meta)
      end)

    metrics ++ optional_metrics
  end

  @doc """
  Load measurements.
  """
  def load_measurements(opts) when is_list(opts) do
    meta = Keyword.get(opts, :meta, [])
    modules = Keyword.get(opts, :specs, [])
    optional_modules = Keyword.get(opts, :optional_specs, [])

    measurements =
      Enum.reduce(modules, [], fn module, measurements ->
        measurements ++ load_measurements_from_module!(module, meta)
      end)

    optional_measurements =
      Enum.reduce(optional_modules, [], fn module, measurements ->
        measurements ++ load_measurements_from_module(module, meta)
      end)

    measurements ++ optional_measurements
  end

  @doc """
  Same as `load_metrics_from_module/2` but raises if the module cannot be loaded.
  """
  def load_metrics_from_module!(module, meta) do
    function = :metrics
    arity = 1

    Code.ensure_loaded!(module)

    if Kernel.function_exported?(module, function, arity) do
      metrics = apply(module, function, [meta])
      log_metrics_loading(module, length(metrics))

      metrics
    else
      raise UndefinedFunctionError, module: module, function: function, arity: arity
    end
  end

  @doc """
  Loads the metrics from given module.
  """
  def load_metrics_from_module(module, meta) do
    function = :metrics
    arity = 1

    Code.ensure_loaded(module)

    if Kernel.function_exported?(module, function, arity) do
      metrics = apply(module, function, [meta])
      log_metrics_loading(module, length(metrics))

      metrics
    else
      []
    end
  end

  defp log_metrics_loading(module, count) do
    Logger.debug(fn ->
      "cozy_telemetry - loading #{count} metrics from #{inspect(module)}"
    end)
  end

  @doc """
  Same as `load_measurements_from_module/2` but raises if the module cannot be loaded.
  """
  def load_measurements_from_module!(module, meta) do
    function = :measurements
    arity = 1

    Code.ensure_loaded!(module)

    if Kernel.function_exported?(module, function, arity) do
      measurements = apply(module, function, [meta])
      log_measurements_loading(module, length(measurements))

      measurements
    else
      raise UndefinedFunctionError, module: module, function: function, arity: arity
    end
  end

  @doc """
  Loads the measurements from given module.
  """
  def load_measurements_from_module(module, meta) do
    function = :measurements
    arity = 1

    Code.ensure_loaded(module)

    if Kernel.function_exported?(module, function, arity) do
      measurements = apply(module, function, [meta])
      log_measurements_loading(module, length(measurements))

      measurements
    else
      []
    end
  end

  defp log_measurements_loading(module, count) do
    Logger.debug(fn ->
      "cozy_telemetry - loading #{count} measurements from #{inspect(module)}"
    end)
  end
end
