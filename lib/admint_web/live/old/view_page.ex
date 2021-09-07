defmodule Admint.Web.ViewPage do
  use Admint.Web, :live_component

  def update(assigns, socket) do
    admint = assigns.admint

    opts = Admint.Page.get_opts(admint.module, admint.current_page)

    data = get_by_id(opts, admint.route.id)

    fields = get_fields(opts)

    admint =
      admint
      |> Map.put(:data, data)
      |> Map.put(:fields, fields)

    {:ok, assign(socket, admint: admint)}
  end

  defp get_by_id(opts, id) do
    query = Admint.Page.query(opts)

    query
    |> Admint.Utils.repo().get(id)
  end

  defp get_fields(opts) do
    Admint.Page.index_fields(opts)
  end
end
