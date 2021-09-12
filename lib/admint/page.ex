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
  import Admint.Definition.Helpers
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
    validate_config(config, @mandatory_config, optionals)
  end

  @spec compile_config(map) :: {:ok, map} | {:error, String.t()}
  def compile_config(config) do
    config =
      config
      |> set_default_config(@optional_config)
      |> set_default_config({:title, Utils.humanize(config.id)})

    cond do
      config.schema == nil and config.render == nil ->
        {:error, "At least one of :schema or :render must be defined"}

      true ->
        config = config |> set_default_config({:render, Admint.Page})
        {:ok, config}
    end
  end

  def render(assigns) do
    admint = assigns.admint
    module = get_module(admint)

    page_id = get_current_page_id(admint)
    page = get_page_by_id(module, page_id)

    # _render = page.config.render

    route = get_page_route(admint)

    case route do
      :index ->
        ~L"""
        Index page
        """

      :view ->
        ~L"""
        View page
        """

      :edit ->
        ~L"""
        Edit page
        """

      :not_found ->
        ~L"""
        Not found
        """
    end

    # ~L"""
    # <%= live_component @socket, render, assigns %>
    # """
  end

  defp get_page_route(admint) do
    path = admint.params.path

    case path do
      [_page_id] -> :index
      [_page_id, id] -> :view
      [_page_id, id, "edit"] -> :edit
      _ -> :not_found
    end
  end
end
