defmodule Admint.Web.Page.EditLive do
  use Admint.Web, :live_component
  import Admint.Definition.Helpers
  # import Admint.Web.Page.Helpers

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
    id = get_current_row_id(admint)
    row = get_by_id(config, id)

    socket =
      socket
      |> assign(:page_id, page_id)
      |> assign(:title, config.title)
      |> assign(:admint, admint)
      |> assign(:row, row)
      |> assign(:changeset, row |> Ecto.Changeset.change())
      |> assign(:fields, fields)

    {:ok, socket}
  end

  @impl true
  def handle_event("cancel", _values, socket) do
    admint = socket.assigns.admint
    {:page, page_id} = get_current_page(admint)
    {:noreply, socket |> push_patch(to: get_page_route(admint, page_id))}
  end

  @impl true
  def handle_event("save", values, socket) do
    admint = socket.assigns.admint
    {:page, page_id} = get_current_page(admint)
    module = admint.module
    page = get_page_by_id(module, page_id)

    config = page.config
    schema = get_schema(config)

    apply(schema, :changeset, [socket.assigns.changeset, values])
    |> Admint.Utils.repo().update()

    {:noreply, socket |> push_patch(to: get_page_route(admint, page_id))}
  end

  defp get_schema(config) do
    config.schema
  end

  defp get_by_id(config, id) do
    schema = get_schema(config)
    query = Admint.Query.query(schema)

    query
    |> Admint.Utils.repo().get(id)
  end

  defp get_fields(config) do
    schema = get_schema(config)
    Admint.Schema.fields(schema)
  end

  defp get_current_row_id(admint) do
    params = admint.params
    path = params.path

    [_page_id, id, "edit"] = path
    id
  end
end
