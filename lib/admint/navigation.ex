defmodule Admint.Navigation do
  def get(module) do
    definition = apply(module, :__admint_definition__, [])

    definition.navigation.entries
    |> Enum.reverse()
    |> Enum.map(fn entry ->
      {id, opts} = entry

      case opts do
        %{type: :page} ->
          {:page, id, get_title(id, opts), []}

        %{entries: entries, opts: opts} ->
          entries =
            entries
            |> Enum.reverse()
            |> Enum.map(fn categ_entry ->
              {id, opts} = categ_entry

              case opts do
                %{type: :page} -> {:page, id, get_title(id, opts), []}
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

  defp get_title(_id, %{opts: %{title: title}}), do: title

  defp get_title(id, _opts), do: get_title(id)

  defp get_title(id) do
    Atom.to_string(id)
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
