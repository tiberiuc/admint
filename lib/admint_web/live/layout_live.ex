defmodule Admint.Web.LayoutLive do
  use Admint.Web, :live_component
  import Admint.Definition.Helpers

  def render_header(assigns) do
    module = get_module(assigns.admint)
    definition = get_definition(module)
    header = definition.config.header
    apply(header, :render, [assigns])
  end

  def render_navigation(assigns) do
    module = get_module(assigns.admint)
    definition = get_definition(module)
    navigation = definition.config.navigation
    apply(navigation, :render, [assigns])
  end

  def render_page(assigns) do
    admint = assigns.admint
    module = get_module(admint)
    definition = get_definition(module)
    current_page = Map.get(admint, :current_page, :empty)

    case current_page do
      :not_found ->
        render_error_page(assigns)

      :empty ->
        ~H"""
        <div></div>
        """

      {:page, _} ->
        page = definition.config.page

        assigns =
          assigns
          |> assign(:page, page)

        ~H"""
        <.live_component id="page" module={@page} {assigns} />
        """

      _ ->
        render_error_page(assigns)
    end
  end

  def render_error_page(assigns) do
    module = get_module(assigns.admint)
    definition = get_definition(module)

    error_page = definition.config.error_page

    assigns =
      assigns
      |> assign(:error_page, error_page)

    # apply(error_page, :render, [assigns])
    ~H"""
    <.live_component id="error_page" module={@error_page} {assigns} />
    """
  end
end
