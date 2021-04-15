defmodule AdmintWeb.ContainerLive do
  use AdmintWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    module = session["admint_module"]

    navigation = Admint.Navigation.get(module)

    first_page =
      navigation
      |> Enum.flat_map(fn entry ->
        case entry do
          {:category, _, _, entries} -> entries
          _ -> [entry]
        end
      end)
      |> Enum.map(fn {_, id, _, _} -> id end)
      |> List.first()

    current_page =
      cond do
        is_bitstring(params["page"]) -> String.to_atom(params["page"])
        true -> first_page
      end

    admint = %{
      module: module,
      base_path: session["base_path"],
      navigation: navigation,
      current_page: current_page
    }

    assigns =
      socket
      |> assign(admint: admint)

    {:ok, assigns}
  end
end
