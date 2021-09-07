defmodule Admint.Web.LayoutLive do
  use Admint.Web, :live_component

  def render_header(assigns) do
    header = assigns.admint.config.header
    apply(header, :render, [assigns])
  end

  def render_navigation(assigns) do
    navigation = assigns.admint.config.navigation
    apply(navigation, :render, [assigns])
  end

  def render_page(assigns) do
    admint = assigns.admint
    current_page = admint.current_page

    case current_page do
      :not_found ->
        render_error_page(assigns)

      :empty ->
        ~L"""
        """

      _ ->
        ~L"""
        <%= @admint.current_page.config.id %>
        """
    end
  end

  def render_error_page(assigns) do
    definition = assigns.admint

    error_page = definition.config.error_page

    apply(error_page, :render, [assigns])
  end
end
