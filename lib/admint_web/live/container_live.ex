defmodule Admint.Web.ContainerLive do
  use Admint.Web, :live_view

  alias Admint.Utils

  @impl true
  def mount(params, session, socket) do
    admint = session["admint"]
    module = admint.module

    definition = Admint.Definition.get_definition(module)

    admint =
      admint
      |> Map.merge(definition)
      |> Map.put(:params, sanitize_params(params))
      |> set_current_page()

    assigns =
      socket
      |> assign(admint: admint)

    {:ok, assigns}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    assigns = socket.assigns
    admint = assigns.admint

    admint =
      admint
      |> Map.put(:params, sanitize_params(params))
      |> set_current_page()

    {:noreply, assign(socket, admint: admint)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <%= live_component @socket, assigns.admint.config.render, assigns %>
    """
  end

  @spec sanitize_params(atom()) :: atom()
  defp sanitize_params(params) do
    path = params["admint_path"]
    query = params |> Map.delete("admint_path")

    %{
      path: path,
      query: query
    }
  end

  @spec set_current_page(atom()) :: atom() | :not_found
  defp set_current_page(admint) do
    path = admint.params.path

    with {:ok, page_id} <- Utils.str_as_existing_atom(hd(path)) do
      page =
        Admint.Definition.get_pages(admint.module)
        |> Map.get(page_id)

      page = if page == nil, do: :not_found, else: page
      admint |> Map.put(:current_page, page)
    else
      {:not_found} ->
        admint |> Map.put(:current_page, :not_found)
    end
  end
end
