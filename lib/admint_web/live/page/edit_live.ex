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
      |> assign(:fields, fields)

    {:ok, socket}
  end

  defp get_by_id(config, id) do
    schema = config.schema
    query = Admint.Query.query(schema)

    query
    |> Admint.Utils.repo().get(id)
  end

  defp get_fields(config) do
    schema = config.schema
    Admint.Schema.fields(schema)
  end

  defp get_current_row_id(admint) do
    params = admint.params
    path = params.path

    [_page_id, id, "edit"] = path
    id
  end
end
