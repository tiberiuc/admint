defmodule Admint.NavigationImpl do
  def get(module) do
    definition = apply(module, :__admint_definition__, [])

    definition.navigation.entries
    |> Enum.reverse()
    |> Enum.map(fn entry ->
      {id, opts} = entry

      case opts do
        %{type: :page} ->
          {:page, id, get_title(id, opts), opts.opts}

        %{entries: entries, opts: opts} ->
          entries =
            entries
            |> Enum.reverse()
            |> Enum.map(fn categ_entry ->
              {id, opts} = categ_entry

              case opts do
                %{type: :page} -> {:page, id, get_title(id, opts), opts.opts}
                _ -> nil
              end
            end)
            |> Enum.filter(fn entry -> entry != nil end)

          {:category, id, get_title(id, opts), entries}

        _ ->
          nil
      end
    end)
    |> Enum.filter(fn entry -> entry != nil end)
  end

  def to_page(socket, assigns, page) do
    router = Admint.Utils.router()
    apply(router, :admint_page_path, [socket, assigns.admint.base_path, Atom.to_string(page)])
  end

  def to_page_id_view(socket, assigns, page, id) do
    router = Admint.Utils.router()

    apply(router, :admint_page_view_path, [
      socket,
      assigns.admint.base_path,
      Atom.to_string(page),
      id
    ])
  end

  def to_page_id_edit(socket, assigns, page, id) do
    router = Admint.Utils.router()

    apply(router, :admint_page_action_path, [
      socket,
      assigns.admint.base_path,
      Atom.to_string(page),
      id,
      :edit
    ])
  end

  def get_index_page_id(module) do
    get_all_pages(module)
    |> Enum.map(fn {_, id, _, _} -> id end)
    |> List.first()
  end

  def get_page_by_id(module, page_id) do
    get_all_pages(module)
    |> Enum.filter(fn {_, id, _, _} -> id == page_id end)
    |> List.first()
  end

  defp get_all_pages(module) do
    get(module)
    |> Enum.flat_map(fn entry ->
      case entry do
        {:category, _, _, entries} -> entries
        entry -> [entry]
      end
    end)
  end

  defp get_title(_id, %{title: title}), do: title
  defp get_title(_id, %{opts: %{title: title}}), do: title

  defp get_title(id, _opts), do: get_title(id)

  defp get_title(id) do
    Admint.Utils.humanize(id)
  end
end
