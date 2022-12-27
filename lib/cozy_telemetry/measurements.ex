defmodule CozyTelemetry.Measurements do
  @moduledoc """
  A behaviour for declaring periodic measurements.

  Any module that wants to run periodic measurements should implement this behaviour.

      defmodule MyApp.Cache do
        use CozyTelemetry.Measurements

        @impl CozyTelemetry.Measurements
        def periodic_measurements(meta) do
          [
            {__MODULE__, :dispatch_stats, []}
          ]
        end
      end

  Then, the declared measurements in above module can be loaded with following configuration:

      config :my_app, CozyTelemetry,
        meta: [],
        metrics: [],
        measurements: [
          MyApp.Cache
        ],
        # ...

  """

  require Logger

  @type meta() :: keyword()

  @callback periodic_measurements(meta()) :: [TelemetryPoller.measurement()]

  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour CozyTelemetry.Measurements
    end
  end

  @doc """
  Same as `load_measurements_from_module/2` but raises if the module cannot be loaded.
  """
  def load_measurements_from_module!(module, meta) do
    function = :periodic_measurements
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
  Loads the measurements from given module.
  """
  def load_measurements_from_module(module, meta) do
    function = :periodic_measurements
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
      "cozy_telemetry - loading measurements from #{inspect(module)}"
    end)
  end
end
