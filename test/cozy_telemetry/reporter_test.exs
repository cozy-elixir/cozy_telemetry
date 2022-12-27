defmodule CozyTelemetry.ReporterTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  defmodule MyApp.Cache do
    use CozyTelemetry.Metrics

    @impl CozyTelemetry.Metrics
    def metrics(_meta) do
      [
        summary("cache.duration",
          unit: {:native, :second},
          tags: [:type, :key]
        )
      ]
    end
  end

  describe "child_spec/1" do
    test "generates right childs specification" do
      assert %{
               id: Telemetry.Metrics.ConsoleReporter,
               start: {Telemetry.Metrics.ConsoleReporter, :start_link, [[metrics: []]]}
             } ==
               CozyTelemetry.Reporter.child_spec(
                 meta: [name: :demo],
                 metrics: [],
                 reporter: {:console, []}
               )
    end

    test "works with existing metrics module" do
      assert %{
               id: Telemetry.Metrics.ConsoleReporter,
               start:
                 {Telemetry.Metrics.ConsoleReporter, :start_link,
                  [
                    [
                      metrics: [
                        %Telemetry.Metrics.Summary{
                          name: [:cache, :duration],
                          event_name: [:cache]
                        }
                      ]
                    ]
                  ]}
             } =
               CozyTelemetry.Reporter.child_spec(
                 meta: [name: :demo],
                 metrics: [MyApp.Cache],
                 reporter: {:console, []}
               )
    end

    test "raises when provided metrics module is invalid" do
      assert_raise ArgumentError,
                   "could not load module YourApp.Repo due to reason :nofile",
                   fn ->
                     CozyTelemetry.Reporter.child_spec(
                       meta: [name: :demo],
                       metrics: [YourApp.Repo],
                       reporter: {:console, []}
                     )
                   end
    end

    test "works with optional metrics module" do
      assert %{
               id: Telemetry.Metrics.ConsoleReporter,
               start:
                 {Telemetry.Metrics.ConsoleReporter, :start_link,
                  [
                    [
                      metrics: [
                        %Telemetry.Metrics.Summary{
                          name: [:cache, :duration],
                          event_name: [:cache]
                        }
                      ]
                    ]
                  ]}
             } =
               CozyTelemetry.Reporter.child_spec(
                 meta: [name: :demo],
                 optional_metrics: [MyApp.Cache],
                 reporter: {:console, []}
               )
    end

    test "works when provided optional metrics module is invalid" do
      assert %{
               id: Telemetry.Metrics.ConsoleReporter,
               start: {Telemetry.Metrics.ConsoleReporter, :start_link, [[metrics: []]]}
             } =
               CozyTelemetry.Reporter.child_spec(
                 meta: [name: :demo],
                 optional_metrics: [YourApp.Repo],
                 reporter: {:console, []}
               )
    end

    test "works with optional reporter" do
      assert %{
               id: TelemetryMetricsStatsd,
               start: {TelemetryMetricsStatsd, :start_link, [[metrics: []]]}
             } ==
               CozyTelemetry.Reporter.child_spec(
                 meta: [name: :demo],
                 metrics: [],
                 reporter: {:statsd, []}
               )
    end

    test "raises and prints error messages when the dependency of optional reporter is missing" do
      fun = fn ->
        assert_raise RuntimeError, "missing dependency - :telemetry_metrics_prometheus", fn ->
          CozyTelemetry.Reporter.child_spec(
            meta: [name: :demo],
            metrics: [],
            reporter: {:prometheus, []}
          )
        end
      end

      assert capture_log(fun) =~ "{:telemetry_metrics_prometheus, version}"
    end
  end
end
