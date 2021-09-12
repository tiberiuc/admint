defmodule Admint.Web.ContainerLive do
  use Admint.Web, :live_view

  import Admint.Definition.Helpers
  alias Admint.Utils

  @impl true
  def mount(params, session, socket) do
    admint = session["admint"]

    admint =
      admint
      |> Map.put(:params, sanitize_params(params))
      |> set_current_page()

    assigns =
      socket
      |> assign(admint: admint)

    {:ok, assigns}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    assigns = socket.assigns
    admint = assigns.admint

    admint =
      admint
      |> Map.put(:params, sanitize_params(params))
      |> set_current_page()

    {:noreply, assign(socket, admint: admint)}
  end

  @impl true
  def render(assigns) do
    admint = assigns.admint
    module = get_module(admint)
    definition = get_definition(module)
    layout_module = definition.config.module
    apply(layout_module, :render, [assigns])
  end

  @spec sanitize_params(map()) :: map()
  defp sanitize_params(params) do
    path = params["admint_path"]
    query = params |> Map.delete("admint_path")

    %{
      path: path,
      query: query
    }
  end

  @spec set_current_page(map()) :: map() | :not_found
  defp set_current_page(admint) do
    path = admint.params.path

    with [page | _] <- path,
         {:ok, page_id} <- Utils.str_as_existing_atom(page) do
      module = get_module(admint)

      page =
        get_pages(module)
        |> Map.get(page_id)

      page = if page == nil, do: :not_found, else: {:page, page_id}
      admint |> Map.put(:current_page, page)
    else
      {:not_found} ->
        admint |> Map.put(:current_page, :not_found)

      _ ->
        admint |> Map.put(:current_page, :empty)
    end
  end
end
