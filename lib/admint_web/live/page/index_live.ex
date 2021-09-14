defmodule Admint.Web.Page.IndexLive do
  use Admint.Web, :live_component
  import Admint.Definition.Helpers
  import Admint.Web.Page.Helpers

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    admint = assigns.admint
    module = admint.module
    {:page, page_id} = get_current_page(admint)
    page = get_page_by_id(module, page_id)

    config = page.config
    fields = get_fields(config)
    rows = get_all(config)

    socket =
      socket
      |> assign(:page_id, page_id)
      |> assign(:title, page.config.title)
      |> assign(:admint, admint)
      |> assign(:rows, rows)
      |> assign(:fields, fields)
      |> assign(:select_all, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("view", params, socket) do
    admint = socket.assigns.admint
    path = get_current_page_view_path(admint, params)

    {:noreply, push_patch(socket, to: path)}
  end

  @impl true
  def handle_event("edit", params, socket) do
    admint = socket.assigns.admint
    path = get_current_page_edit_path(admint, params)

    {:noreply, push_patch(socket, to: path)}
  end

  @impl true
  def handle_event("delete", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_select_all", params, socket) do
    value = Map.get(params, "value", false) == "true"

    {:noreply, update(socket, :select_all, fn _ -> value end)}
  end

  defp get_all(config) do
    schema = config.schema
    query = Admint.Query.query(schema)

    query
    |> Admint.Utils.repo().all()
    |> Enum.map(fn row ->
      id = Admint.Schema.get_primary_key_value(schema, row)

      {id, row}
    end)
  end

  defp get_fields(config) do
    schema = config.schema
    Admint.Schema.fields(schema)
  end
end
