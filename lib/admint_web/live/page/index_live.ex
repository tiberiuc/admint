defmodule Admint.Web.Page.IndexLive do
  use Admint.Web, :live_component
  import Admint.Definition.Helpers
  import Admint.Web.Page.Helpers

  @per_page 10

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

    query = admint.params.query

    sort = %{sort_by: query["sort_by"] |> to_atom(), sort: query["sort"] |> to_atom()}
    pagination = %{page: query["page"] || 1, per_page: query["per_page"] || @per_page}

    config = page.config
    fields = get_fields(config)

    query_params = Map.merge(sort, pagination)
    rows = get_all(config, query_params)

    socket =
      socket
      |> assign(:page_id, page_id)
      |> assign(:title, config.title)
      |> assign(:admint, admint)
      |> assign(:rows, rows)
      |> assign(:fields, fields)
      |> assign(:select_all, false)
      |> assign(sort: sort)
      |> assign(pagination: pagination)

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
  def handle_event("delete", values, socket) do
    id = values["value"]
    admint = socket.assigns.admint
    module = admint.module
    {:page, page_id} = get_current_page(admint)
    page = get_page_by_id(module, page_id)

    config = page.config
    schema = config.schema
    query = Admint.Query.query(schema)

    query |> Admint.Utils.repo().get(id) |> Admint.Utils.repo().delete()

    rows = get_all(config)
    socket = socket |> assign(rows: rows)

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_select_all", params, socket) do
    value = Map.get(params, "value", false) == "true"
    assigns = socket.assigns

    rows =
      assigns.rows
      |> Enum.map(fn row -> %{row | selected: value} end)

    {:noreply,
     socket
     |> assign(select_all: value, rows: rows)}
  end

  @impl true
  def handle_event("toggle_select", params, socket) do
    id = params["id"]

    assigns = socket.assigns

    rows =
      assigns.rows
      |> Enum.map(fn row ->
        selected =
          if to_string(row.id) == id do
            !row.selected
          else
            row.selected
          end

        %{row | selected: selected}
      end)

    all_selected = is_all_selected(rows)

    {:noreply, socket |> assign(rows: rows, select_all: all_selected)}
  end

  @impl true
  def handle_event("change_sort", params, socket) do
    assigns = socket.assigns
    %{sort_by: sort_by, sort: sort} = assigns.sort
    field_id = params["id"] |> to_atom()

    sort =
      cond do
        field_id != sort_by ->
          %{sort_by: field_id, sort: :asc}

        sort == :asc ->
          %{sort_by: field_id, sort: :desc}

        true ->
          %{sort_by: nil, sort: nil}
      end

    path = update_query(assigns.admint, sort)

    query_params = Map.merge(sort, assigns.pagination)
    admint = assigns.admint
    module = admint.module
    {:page, page_id} = get_current_page(admint)
    page = get_page_by_id(module, page_id)
    config = page.config
    rows = get_all(config, query_params)

    socket =
      socket
      |> assign(sort: sort)
      |> assign(rows: rows)
      |> push_patch(to: path)

    {:noreply, socket}
  end

  defp is_all_selected(rows) do
    rows
    |> Enum.map(fn %{selected: selected} -> selected end)
    |> Enum.find(fn sel -> sel == false end) == nil
  end

  defp get_all(config, opts \\ %{}) do
    schema = config.schema
    query = Admint.Query.query(schema, opts)

    query
    |> Admint.Utils.repo().all()
    |> Enum.map(fn row ->
      id = Admint.Schema.get_primary_key_value(schema, row)

      %{id: id, selected: false, data: row}
    end)
  end

  defp get_fields(config) do
    schema = config.schema
    Admint.Schema.fields(schema)
  end

  defp to_atom(nil), do: nil

  defp to_atom(str) do
    try do
      String.to_existing_atom(str)
    rescue
      _ -> nil
    end
  end

  defp update_query(admint, query) do
    path = ([admint.base_path] ++ admint.params.path) |> Enum.join("/")
    query = Enum.map(query, fn {key, value} -> {to_string(key), value} end) |> Enum.into(%{})
    query = Map.merge(admint.params.query, query)

    query = "?" <> (Enum.map(query, fn {key, value} -> "#{key}=#{value}" end) |> Enum.join("&"))
    path <> query
  end
end
