defmodule CozyTelemetry.Reporter do
  @moduledoc """
  A behaviour for declaring reporters.
  """

  @type init_arg :: keyword()

  @type child_spec() :: %{
          id: term(),
          start: term(),
          type: term()
        }

  @doc """
  Checks required dependencies.

  When dependencies are missing, an exception should be raised.
  """
  @callback check_deps() :: :ok

  @doc """
  Generates child specification for starting a reporter.
  """
  @callback child_spec(init_arg) :: child_spec()

  require Logger

  @doc """
  Prints consistent error messages of missing package for reporters.
  """
  def print_missing_package(package_name) do
    Logger.error("""
    Could not find #{inspect(package_name)} dependency.

    Please add #{inspect(package_name)} to your dependencies:

        {#{inspect(package_name)}, version}

    """)
  end
end
