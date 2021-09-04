defmodule Admint.Web.ContainerLive do
  use Admint.Web, :live_view

  alias Admint.Utils

  @impl true
  def mount(params, session, socket) do
    admint = session["admint"]
    module = admint.module

    navigation = Admint.Definition.get_navigation(module)

    admint =
      admint
      |> Map.put(:navigation, navigation)
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
      |> IO.inspect()

    {:noreply, assign(socket, admint: admint)}
  end

  @spec sanitize_params(atom()) :: atom()
  defp sanitize_params(params) do
    path = params["admint_path"] |> IO.inspect(label: "----")
    query = params |> Map.delete("admint_path")

    %{
      path: path,
      query: query
    }
  end

  @spec set_current_page(atom()) :: atom() | :not_found
  defp set_current_page(admint) do
    path =
      admint.params.path
      |> IO.inspect()

    with {:ok, page_id} <- Utils.str_as_existing_atom(hd(path)) do
      IO.inspect(page_id)

      page =
        Admint.Definition.get_pages(admint.module)
        |> IO.inspect()
        # |> Map.get(:pages)
        |> Map.get(page_id)

      page = if page == nil, do: :not_found, else: page
      admint |> Map.put(:current_page, page)
    else
      {:not_found} ->
        admint |> Map.put(:current_page, :not_found)
    end
  end
end
