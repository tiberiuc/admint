defmodule Admint.Layout do
  @callback validate_config(map()) :: :ok | {:error, String.t()}
  @callback compile_config(map()) :: {:ok, map()} | {:error, String.t()}
  @callback render(map()) :: any()

  use Admint.Web, :live_component

  import Admint.Definition.Helpers

  @mandatory_config [:module]

  @optional_config [
    {:page, Admint.Page},
    {:navigation, Admint.Navigation},
    {:header, Admint.Header},
    {:error_page, Admint.ErrorPage},
    {:render, Admint.Web.LayoutLive}
  ]

  defmacro __using__(_config) do
    quote do
      @behaviour Admint.Layout
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
    definition = get_definition(module)
    config = definition.config
    render = config.render

    ~L"""
    <%= live_component @socket, render, assigns |> Map.put(:id, :admint_layout ) %>
    """
  end
end
