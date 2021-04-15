defmodule AdmintWeb.ContainerLive do
  use AdmintWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    module = session["admint_module"]

    current_page =
      cond do
        is_bitstring(params["page"]) -> String.to_atom(params["page"])
        true -> ""
      end

    navigation = Admint.Navigation.get(module)

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
