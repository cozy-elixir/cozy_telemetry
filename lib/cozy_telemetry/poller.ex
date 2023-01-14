defmodule CozyTelemetry.Poller do
  @moduledoc """
  The application that fetches measurements periodically.
  """

  alias CozyTelemetry.Measurements

  @doc """
  Builds a child specifications.
  """
  def child_spec(init_arg) do
    meta = Keyword.get(init_arg, :meta, [])
    measurements_modules = Keyword.get(init_arg, :measurements, [])
    optional_measurements_modules = Keyword.get(init_arg, :optional_measurements, [])

    measurements = load_measurements(measurements_modules, optional_measurements_modules, meta)

    init_arg
    |> Keyword.get(:poller, [])
    |> generate_child_spec(measurements)
  end

  defp load_measurements(modules, optional_modules, meta)
       when is_list(modules) and is_list(optional_modules) do
    measurements =
      Enum.reduce(modules, [], fn module, measurements ->
        measurements ++ Measurements.load_measurements_from_module!(module, meta)
      end)

    optional_measurements =
      Enum.reduce(optional_modules, [], fn module, measurements ->
        measurements ++ Measurements.load_measurements_from_module(module, meta)
      end)

    measurements ++ optional_measurements
  end

  defp generate_child_spec(opts, measurements) do
    opts = Keyword.put(opts, :measurements, measurements)
    :telemetry_poller.child_spec(opts)
  end
end
