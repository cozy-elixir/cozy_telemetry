defmodule CozyTelemetry.Metrics do
  @moduledoc """
  A behaviour for declaring metrics.

  Any module that wants to exposing metrics should reference this behaviour.

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

  Then, the declared metrics in above module can be loaded with following configuration:

    config :my_app, CozyTelemetry,
      meta: [],
      metrics: [
        MyApp.Cache
      ],
      # ...

  """

  @type meta() :: keyword()

  @callback metrics(meta()) :: [Telemetry.Metrics.t()]

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Telemetry.Metrics

      @behaviour CozyTelemetry.Metrics
    end
  end

  @doc """
  Same as `load_metrics_from_module/2` but raises if the module cannot be loaded.
  """
  def load_metrics_from_module!(module, meta) do
    function = :metrics
    arity = 1

    Code.ensure_loaded!(module)

    if Kernel.function_exported?(module, function, arity) do
      log(module)
      apply(module, function, [meta])
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
      log(module)
      apply(module, function, [meta])
    else
      []
    end
  end

  defp log(module) do
    Logger.debug(fn ->
      "cozy_telemetry - loading metrics from #{inspect(module)}"
    end)
  end
end
