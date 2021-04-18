defmodule AdmintWeb.ContainerLive do
  use AdmintWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    module = session["admint_module"]

    navigation = Admint.Navigation.get(module)

    admint =
      %{
        module: module,
        base_path: session["base_path"],
        navigation: navigation
      }
      |> Map.merge(get_current_page_route(params, module))

    assigns =
      socket
      |> assign(admint: admint)

    {:ok, assigns}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    assigns = socket.assigns
    admint = assigns.admint

    module = admint.module

    admint = admint |> Map.merge(get_current_page_route(params, module))

    {:noreply, assign(socket, admint: admint)}
  end

  defp get_current_page_route(params, module) do
    first_page = Admint.Navigation.get_index_page_id(module)

    current_page = get_param_as_atom(params, "page", first_page)
    action = get_param_as_atom(params, "action", :index)

    %{
      current_page: current_page,
      route: %{
        action: action
      }
    }
  end

  defp get_param_as_atom(params, name, default) do
    cond do
      is_bitstring(params[name]) -> String.to_atom(params[name])
      true -> default
    end
  end
end
