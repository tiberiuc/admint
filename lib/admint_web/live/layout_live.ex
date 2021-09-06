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
end
