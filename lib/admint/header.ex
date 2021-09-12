defmodule Admint.Header do
  @callback validate_config(map()) :: :ok | {:error, String.t()}
  @callback compile_config(map()) :: {:ok, map()} | {:error, String.t()}
  @callback render(map()) :: any()

  @type t :: %__MODULE__{
          __stacktrace__: Admint.Stacktrace.t(),
          config: map
        }

  @enforce_keys [:__stacktrace__, :config]
  defstruct [:__stacktrace__, :config]

  use Admint.Web, :live_component

  import Admint.Definition.Helpers

  defmacro __using__(_config) do
    quote do
      @behaviour Admint.Header
    end
  end

  @mandatory_config [:module]

  @optional_config [
    {:render, Admint.Web.HeaderLive}
  ]

  @spec validate_config(map) :: :ok | {:error, String.t()}
  def validate_config(config) do
    optionals = @optional_config |> Enum.map(fn {id, _} -> id end)
    validate_config(config, @mandatory_config, optionals)
  end

  @spec compile_config(map) :: {:ok, map} | {:error, String.t()}
  def compile_config(config) do
    config = set_default_config(config, @optional_config)

    {:ok, config}
  end

  def render(assigns) do
    admint = assigns.admint
    module = get_module(admint)
    header = get_header(module)
    render = header.config.render

    ~L"""
    <%= live_component @socket, render, %{assigns | id: :admint_header } %>
    """
  end
end
