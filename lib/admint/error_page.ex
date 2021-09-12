defmodule Admint.ErrorPage do
  @callback validate_config(map()) :: :ok | {:error, String.t()}
  @callback compile_config(map()) :: {:ok, map()} | {:error, String.t()}
  @callback render(map()) :: term()

  @type t :: %__MODULE__{
          __stacktrace__: Admint.Stacktrace.t(),
          config: map
        }

  @enforce_keys [:__stacktrace__, :config]
  defstruct [:__stacktrace__, :config]

  use Admint.Web, :live_component
  import Admint.Definition.Helpers

  @mandatory_config [:module]

  @optional_config [
    {:render, Admint.Web.ErrorPageLive}
  ]

  defmacro __using__(_config) do
    quote do
      @behaviour Admint.ErrorPage
    end
  end

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
    error_page = get_error_page(module)
    render = error_page.config.render

    ~L"""
    <%= live_component @socket, render, %{assigns | id: :admint_error_page } %>
    """
  end
end
