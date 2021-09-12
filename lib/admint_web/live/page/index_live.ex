defmodule Admint.Web.Page.IndexLive do
  use Admint.Web, :live_component

  def mount(socket) do
    IO.inspect("----")
    {:ok, socket}
  end

  def update(assigns, socket) do
    admint = assigns.admint
    existing_page = Map.get(assigns, :page) |> IO.inspect(label: "existing page:")
    page_id = get_current_page(admint) |> IO.inspect(label: "new page")

    socket = socket |> assign(:page, page_id) |> assign(:admint, admint)
    {:ok, socket}
  end

  @impl true
  def handle_event("click", params, socket) do
    IO.inspect(params, label: "Params:")
    IO.inspect(socket.assigns, label: "Assigns:")
    {:noreply, socket}
  end
end
