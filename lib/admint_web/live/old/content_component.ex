defmodule Admint.Web.ContentComponent do
  use Phoenix.LiveComponent

  def update(assigns, socket) do
    admint = assigns.admint

    opts = Admint.Page.get_opts(admint.module, admint.current_page)

    admint = admint |> Map.put(:page_opts, opts)

    {render, error_message} =
      Admint.Page.get_render(admint.route.action, opts, admint.current_page)

    # case admint.route.action do
    #   :index -> Admint.Page.get_render(:index, opts, admint.current_page)
    #   :view -> Admint.Page.get_render(:view, opts, admint.current_page)
    #   action -> {nil, "Unknown action \":#{action}\" for page \":#{admint.current_page}\""}
    # end

    {:ok, assign(socket, admint: admint, render: render, error_message: error_message)}
  end

  def render(assigns) do
    ~L"""
    <%= if @error_message do %>
      <div class="notification is-danger">
        <%= @error_message %>
      </div>
    <% end %>
    <%= if @render do %>
      <%= live_component @socket, @render, admint: @admint, id: :page %>
    <% end %>
    """
  end
end
