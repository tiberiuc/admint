defmodule Admint do
  @moduledoc """
  Admint keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  defmacro admint(route, module, do: block) do
    base_path = route |> String.trim_trailing("/")

    base_path_id =
      route
      |> String.split("/")
      |> Enum.filter(fn p -> p != "" and !String.starts_with?(p, ":") end)
      |> Enum.join("_")
      |> String.to_atom()

    quote do
      scope unquote(route), Admint.Web do
        unquote(block)

        pipe_through :admint_pipeline

        live_session :admin,
          session: %{
            "admint" => %{
              module: unquote(module),
              base_path: unquote(base_path)
            }
          } do
          live "/*admint_path", ContainerLive, unquote(base_path_id), as: :admint
        end
      end
    end
  end

  def router do
    quote do
      import Admint

      pipeline :admint_pipeline do
        plug :put_root_layout, html: {Admint.Web.Layouts, :admint_root}
      end
    end
  end

  def endpoint do
    quote do
      plug Plug.Static,
        at: "/admint",
        from: :admint,
        gzip: false,
        only: ~w(assets)
    end
  end

  def definition do
    quote do
      use Admint.Definition
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__(which) when is_list(which) do
    which |> Enum.each(&apply(__MODULE__, &1, []))
  end
end
