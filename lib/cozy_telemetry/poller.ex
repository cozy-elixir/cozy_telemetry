defmodule CozyTelemetry.Poller do
  @moduledoc """
  The application that fetches measurements periodically.
  """

  alias CozyTelemetry.Spec

  @doc """
  Builds a child specifications.
  """
  def child_spec(init_arg) do
    measurements = Spec.load_measurements(init_arg)

    init_arg
    |> Keyword.get(:poller, [])
    |> generate_child_spec(measurements)
  end

  defp generate_child_spec(opts, measurements) do
    opts = Keyword.put(opts, :measurements, measurements)
    :telemetry_poller.child_spec(opts)
  end
end
