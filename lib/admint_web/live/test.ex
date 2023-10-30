defmodule Admint.Web.Test do
  # use Admint.Web, :live_component
  use Phoenix.LiveComponent

  # def mount(_params, _session, socket) do
  #   {:ok, assign(socket, entries: ["a", "b", "c"])}
  # end

  @impl true
  def update(_assigns, socket) do
    socket =
      socket
      |> assign(entries: ["a", "d", "e"])

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <p>aaaaaa</p>
      <%= for i <- ["a", "b", "c"] do %>
        <%= case i do %>
          <% "a" -> %>
            "is a"
          <% _ -> %>
            <%= i %>
        <% end %>
      <% end %>
      <br />
      <%= for i <- @entries do %>
        <%= case i do %>
          <% "a" -> %>
            "is a"
          <% _ -> %>
            <%= i %>
        <% end %>
      <% end %>
    </div>
    """
  end
end
