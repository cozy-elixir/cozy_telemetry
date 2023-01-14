# CozyTelemetry

[![CI](https://github.com/cozy-elixir/cozy_telemetry/actions/workflows/ci.yml/badge.svg)](https://github.com/cozy-elixir/cozy_telemetry/actions/workflows/ci.yml)

> Provides a modular approach for using [beam-telemetry](https://github.com/beam-telemetry) packages.

## Installation

Add `cozy_telemetry` to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cozy_telemetry, version}
  ]
end
```

> **Note**
>
> `cozy_telemetry` is depending on following packages:
>
> - `telemetry`
> - `telemetry_poller`
> - `telemetry_metrics`
>
> If you want to use them, there is no need to add them to `mix.exs` explicitly. They are available after you adding `cozy_telemetry`.

## Usage

For more information, see the [documentation](https://hexdocs.pm/cozy_telemetry/CozyTelemetry.html).

## License

Apache License 2.0
