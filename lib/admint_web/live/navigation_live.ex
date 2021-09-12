defmodule Admint.Web.NavigationLive do
  use Admint.Web, :live_component
  import Admint.Definition.Helpers

  @impl true
  def update(assigns, socket) do
    admint = assigns.admint
    module = get_module(admint)
    navigation = get_navigation(module)
    pages = get_pages(module)
    categories = get_categories(module)

    socket =
      socket
      |> assign(
        admint: admint,
        navigation: navigation,
        categories: categories,
        pages: pages
      )

    {:ok, socket}
  end
end
