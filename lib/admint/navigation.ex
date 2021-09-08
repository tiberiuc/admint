defmodule Admint.NavigationEntry do
  @type page :: {:page, atom}
  @type category :: {:category, [page]}
  @type t :: page | category
end

defmodule Admint.Navigation do
  @callback validate_config(map()) :: :ok | {:error, String.t()}
  @callback compile_config(map()) :: {:ok, map()} | {:error, String.t()}
  @callback render(map()) :: any()

  @type t :: %__MODULE__{
          __stacktrace__: Admint.Stacktrace.t(),
          entries: [Admint.NavigationEntry.t()],
          config: map
        }

  @enforce_keys [:__stacktrace__, :entries, :config]
  defstruct [:__stacktrace__, :entries, :config]

  use Admint.Web, :live_component
  alias Admint.Utils

  @mandatory_config [:module]

  @optional_config [
    {:render, Admint.Web.NavigationLive}
  ]

  defmacro __using__(_config) do
    quote do
      @behaviour Admint.Navigation
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

  @spec render(map()) :: any
  def render(assigns) do
    admint = assigns.admint
    render = admint.navigation.config.render

    ~L"""
    <%= live_component @socket, render, assigns %>
    """
  end
end
