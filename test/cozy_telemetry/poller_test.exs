defmodule CozyTelemetry.PollerTest do
  use ExUnit.Case

  defmodule MyApp.Cache.TelemetrySpec do
    use CozyTelemetry.Spec

    @impl true
    def measurements(_meta) do
      [
        {__MODULE__, :dispatch_stats, []}
      ]
    end
  end

  describe "child_spec/1" do
    test "generates right childs specification" do
      assert %{
               id: :telemetry_poller,
               start:
                 {:telemetry_poller, :start_link,
                  [
                    [
                      measurements: [],
                      period: 5000
                    ]
                  ]}
             } ==
               CozyTelemetry.Poller.child_spec(
                 meta: [name: :demo],
                 specs: [],
                 poller: [period: 5000]
               )
    end

    test "works with existing measurements module" do
      assert %{
               id: :telemetry_poller,
               start:
                 {:telemetry_poller, :start_link,
                  [
                    [
                      measurements: [
                        {CozyTelemetry.PollerTest.MyApp.Cache.TelemetrySpec, :dispatch_stats, []}
                      ],
                      period: 5000
                    ]
                  ]}
             } ==
               CozyTelemetry.Poller.child_spec(
                 meta: [name: :demo],
                 specs: [MyApp.Cache.TelemetrySpec],
                 poller: [period: 5000]
               )
    end

    test "raises when provided measurements module is invalid" do
      assert_raise ArgumentError,
                   "could not load module YourApp.Repo due to reason :nofile",
                   fn ->
                     CozyTelemetry.Poller.child_spec(
                       meta: [name: :demo],
                       specs: [YourApp.Repo],
                       poller: [period: 5000]
                     )
                   end
    end

    test "works with optional measurements module" do
      assert %{
               id: :telemetry_poller,
               start:
                 {:telemetry_poller, :start_link,
                  [
                    [
                      measurements: [
                        {CozyTelemetry.PollerTest.MyApp.Cache.TelemetrySpec, :dispatch_stats, []}
                      ],
                      period: 5000
                    ]
                  ]}
             } ==
               CozyTelemetry.Poller.child_spec(
                 meta: [name: :demo],
                 optional_specs: [MyApp.Cache.TelemetrySpec],
                 poller: [period: 5000]
               )
    end

    test "works when provided optional measurements module is invalid" do
      assert %{
               id: :telemetry_poller,
               start:
                 {:telemetry_poller, :start_link,
                  [
                    [
                      measurements: [],
                      period: 5000
                    ]
                  ]}
             } ==
               CozyTelemetry.Poller.child_spec(
                 meta: [name: :demo],
                 optional_specs: [YourApp.Repo],
                 poller: [period: 5000]
               )
    end
  end
end
