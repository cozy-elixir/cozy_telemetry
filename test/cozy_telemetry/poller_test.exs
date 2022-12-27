defmodule CozyTelemetry.PollerTest do
  use ExUnit.Case

  defmodule MyApp.Cache do
    use CozyTelemetry.Measurements

    @impl CozyTelemetry.Measurements
    def periodic_measurements(_meta) do
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
                 measurements: [],
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
                        {CozyTelemetry.PollerTest.MyApp.Cache, :dispatch_stats, []}
                      ],
                      period: 5000
                    ]
                  ]}
             } ==
               CozyTelemetry.Poller.child_spec(
                 meta: [name: :demo],
                 measurements: [
                   MyApp.Cache
                 ],
                 poller: [period: 5000]
               )
    end

    test "raises when provided measurements module is invalid" do
      assert_raise ArgumentError,
                   "could not load module YourApp.Repo due to reason :nofile",
                   fn ->
                     CozyTelemetry.Poller.child_spec(
                       meta: [name: :demo],
                       measurements: [YourApp.Repo],
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
                        {CozyTelemetry.PollerTest.MyApp.Cache, :dispatch_stats, []}
                      ],
                      period: 5000
                    ]
                  ]}
             } ==
               CozyTelemetry.Poller.child_spec(
                 meta: [name: :demo],
                 optional_measurements: [
                   MyApp.Cache
                 ],
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
                 optional_measurements: [YourApp.Repo],
                 poller: [period: 5000]
               )
    end
  end
end
