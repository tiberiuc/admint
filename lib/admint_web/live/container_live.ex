defmodule AdmintWeb.ContainerLive do
  use AdmintWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    module = session["admint_module"]
    IO.inspect(params)

    admint = %{
      module: module,
      base_path: session["base_path"],
      navigation: [
        {:page, :a, "Dashboard", []},
        {:category, :ca, "General", []},
        {:page, :b, "Clients", []},
        {:category, :ca, "Transactions",
         [
           {:page, :c, "Payments", []},
           {:page, :d, "Balance", []}
         ]},
        {:page, :e, "Invitations", []}
      ]
    }

    assigns =
      socket
      |> assign(admint: admint)

    {:ok, assigns}
  end
end
