defmodule Admint.Web do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use Admint.Web, :controller
      use Admint.Web, :html

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  # def controller do
  #   quote do
  #     use Phoenix.Controller, namespace: Admint.Web

  #     import Plug.Conn
  #     import Admint.Web.Gettext
  #     alias unquote(Admint.Utils.router()), as: Routes
  #   end
  # end

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(html_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {Admint.Web.Layouts, :admint}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import Admint.Web.CoreComponents
      import Admint.Web.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      import Admint.Web.Helpers

      unquote(verified_routes())

      alias unquote(Admint.Utils.router()), as: Routes
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: Admint.Web.Endpoint,
        router: Admint.Web.Router,
        statics: Admint.Web.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
