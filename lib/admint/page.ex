defmodule Admint.Page do
  @callback validate_config(map()) :: :ok | {:error, String.t()}
  @callback compile_config(map()) :: {:ok, map()} | {:error, String.t()}
  @callback render(map()) :: term()

  @type t :: %__MODULE__{
          __stacktrace__: Admint.Stacktrace.t(),
          config: map
        }

  @enforce_keys [:__stacktrace__, :config]
  defstruct [:__stacktrace__, :config]

  defmacro __using__(_config) do
    quote do
      @behaviour Admint.Page
    end
  end

  use Admint.Web, :live_component
  alias Admint.Utils

  @mandatory_config [:module, :id]
  @optional_config [
    {:schema, nil},
    {:title, nil},
    {:render, nil}
  ]

  @spec validate_config(map) :: :ok | {:error, String.t()}
  def validate_config(config) do
    optionals = @optional_config |> Enum.map(fn {id, _} -> id end)
    Utils.validate_config(config, @mandatory_config, optionals)
  end

  @spec compile_config(map) :: {:ok, map} | {:error, String.t()}
  def compile_config(config) do
    config =
      config
      |> Utils.set_default_config(@optional_config)
      |> Utils.set_default_config({:title, Utils.humanize(config.id)})

    cond do
      config.schema == nil and config.render == nil ->
        {:error, "At least one of :schema or :render must be defined"}

      true ->
        config = config |> Utils.set_default_config({:render, Admint.Page})
        {:ok, config}
    end
  end

  def render(assigns) do
    admint = assigns.admint

    page_id = get_current_page_id(admint)
    page = admint.pages[page_id]

    render = page.config.render |> IO.inspect()

    ~L"""
    <%= live_component @socket, render, assigns %>
    """
  end
end
