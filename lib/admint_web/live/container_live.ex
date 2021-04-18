defmodule AdmintWeb.ContainerLive do
  use AdmintWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    module = session["admint_module"]

    navigation = Admint.Navigation.get(module)

    first_page = Admint.Navigation.get_index_page_id(module)

    current_page = get_param_as_atom(params, "page", first_page)
    action = get_param_as_atom(params, "action", :index)

    admint = %{
      module: module,
      base_path: session["base_path"],
      navigation: navigation,
      current_page: current_page,
      route: %{
        action: action
      }
    }

    assigns =
      socket
      |> assign(admint: admint)

    {:ok, assigns}
  end

  defp get_param_as_atom(params, name, default \\ nil) do
    cond do
      is_bitstring(params[name]) -> String.to_atom(params[name])
      true -> default
    end
  end
end
