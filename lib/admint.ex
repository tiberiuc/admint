defmodule Admint do
  @moduledoc """
  Admint keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  defmacro admint(route, module, do: block) do
    path =
      route
      |> String.split("/")
      |> Enum.filter(fn p -> p != "" and !String.starts_with?(p, ":") end)
      |> Enum.join("_")
      |> String.to_atom()

    quote do
      scope unquote(route), Admint.Web do
        unquote(block)

        pipe_through :admint_pipeline

        # live "/", ContainerLive, unquote(path),
        #           as: :admint,
        #           session: %{"admint_module" => unquote(module), "base_path" => unquote(path)}
        # 
        #         live "/:page", ContainerLive, unquote(path),
        #           as: :admint_page,
        #           session: %{"admint_module" => unquote(module), "base_path" => unquote(path)}
        # 
        #         live "/:page/:id", ContainerLive, unquote(path),
        #           as: :admint_page_view,
        #           session: %{"admint_module" => unquote(module), "base_path" => unquote(path)}
        # 
        #         live "/:page/:id/:action", ContainerLive, unquote(path),
        #           as: :admint_page_action,
        #           session: %{"admint_module" => unquote(module), "base_path" => unquote(path)}
        live "/*", ContainerLive, unquote(path),
          as: :admint,
          session: %{"definition" => unquote(module), "path" => unquote(path)}
      end
    end
  end

  def router do
    quote do
      import Admint

      pipeline :admint_pipeline do
        plug :put_root_layout, {Admint.Web.RootLayoutView, :root}
      end
    end
  end

  def endpoint do
    quote do
      plug Plug.Static,
        at: "/admint",
        from: :admint,
        gzip: false,
        only: ~w(css fonts images js)
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
