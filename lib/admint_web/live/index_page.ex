defmodule Admint.Web.IndexPage do
  use Admint.Web, :live_component

  def update(assigns, socket) do
    admint = assigns.admint

    opts = Admint.Page.get_opts(admint.module, admint.current_page)

    data = get_all(opts)
    fields = get_fields(opts)

    admint =
      admint
      |> Map.put(:data, data)
      |> Map.put(:fields, fields)
      |> Map.put(:index, %{select_all: false})

    {:ok, assign(socket, admint: admint)}
  end

  def handle_event("view", params, socket) do
    admint = socket.assigns.admint

    path =
      Admint.Navigation.to_page_id_view(
        socket,
        socket.assigns,
        admint.current_page,
        params["value"]
      )

    {:noreply, push_patch(socket, to: path)}
  end

  def handle_event("edit", params, socket) do
    admint = socket.assigns.admint

    path =
      Admint.Navigation.to_page_id_edit(
        socket,
        socket.assigns,
        admint.current_page,
        params["value"]
      )

    {:noreply, push_patch(socket, to: path)}
  end

  def handle_event("delete", _, socket) do
    {:noreply, socket}
  end

  def handle_event("toggle_select_all", params, socket) do
    value = Map.get(params, "value", false) == "true"

    {:noreply,
     update(socket, :admint, fn admint ->
       %{admint | index: %{admint.index | select_all: value}}
     end)}
  end

  defp get_all(opts) do
    query = Admint.Page.query(opts)
    schema = Admint.Page.get_schema(opts)

    query
    |> Admint.Utils.repo().all()
    |> Enum.map(fn row ->
      id = Admint.Schema.get_primary_key_value(schema, row)

      {id, row}
    end)
  end

  defp get_fields(opts) do
    Admint.Page.index_fields(opts)
  end
end
