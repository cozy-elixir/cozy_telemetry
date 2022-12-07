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
end
