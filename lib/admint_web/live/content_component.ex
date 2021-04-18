defmodule AdmintWeb.ContentComponent do
  use Phoenix.LiveComponent

  def update(assigns, socket) do
    admint = assigns.admint

    opts = Admint.Page.get_opts(admint.module, admint.current_page)

    admint = admint |> Map.put(:page_opts, opts)

    {render, error_message} =
      case admint.route.action do
        :index -> get_page_render(:index, opts, admint.current_page)
        action -> {nil, "Unknown action \":#{action}\" for page \":#{admint.current_page}\""}
      end

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
      <%= live_component @socket, @render, admint: @admint %>
    <% end %>
    """
  end

  defp get_page_render(:index, opts, current_page) do
    cond do
      Map.get(opts, :render) != nil ->
        {opts.render, nil}

      Map.get(opts, :schema) != nil ->
        {AdmintWeb.ListPage, nil}

      true ->
        {nil,
         "Unable to render page \":#{current_page}\" it must have either \":render\" or \":schema\" defined"}
    end
  end
end
