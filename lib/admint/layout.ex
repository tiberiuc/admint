defmodule Admint.Layout do
  @callback validate_config(map()) :: :ok | {:error, String.t()}
  @callback compile_config(map()) :: {:ok, map()} | {:error, String.t()}
  @callback render(map()) :: any()

  use Admint.Web, :live_view

  alias Admint.Utils

  @mandatory_config [:module]

  @optional_config [
    {:page_module, Admint.Page},
    {:navigation_module, Admint.Navigation},
    {:header_module, Admint.Header},
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
    Utils.validate_config(config, @mandatory_config, optionals)
  end

  @spec compile_config(map) :: {:ok, map} | {:error, String.t()}
  def compile_config(config) do
    config = Utils.set_default_config(config, @optional_config)

    {:ok, config}
  end

  def render(assigns) do
    admint = assigns.admint
    config = admint.config
    render = config.render

    ~L"""
    <%= live_component @socket, render, assigns %>
    """
  end
end
