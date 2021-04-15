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
      scope unquote(route), AdmintWeb do
        unquote(block)
        pipe_through :admint_pipeline

        live "/", ContainerLive, unquote(path),
          as: :admint,
          session: %{"admint_module" => unquote(module), "base_path" => unquote(path)}

        live "/:page", ContainerLive, unquote(path),
          as: :admint_page,
          session: %{"admint_module" => unquote(module), "base_path" => unquote(path)}
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      import Admint

      pipeline :admint_pipeline do
        plug :put_root_layout, {AdmintWeb.LayoutView, :root}
      end
    end
  end
end
