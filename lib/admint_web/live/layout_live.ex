defmodule Admint.Web.LayoutLive do
  use Admint.Web, :live_component

  def render_header(assigns) do
    header_module = assigns.admint.config.header_module
    apply(header_module, :render, [assigns])
  end

  def render_navigation(assigns) do
    navigation_module = assigns.admint.config.navigation_module
    apply(navigation_module, :render, [assigns])
  end
end
