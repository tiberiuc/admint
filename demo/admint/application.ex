defmodule Admint.Demo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Admint.Demo.Repo,
      # Start the Telemetry supervisor
      AdmintWeb.Demo.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Admint.Demo.PubSub},
      # Start the Endpoint (http/https)
      AdmintWeb.Demo.Endpoint
      # Start a worker by calling: Admint.Worker.start_link(arg)
      # {Admint.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Admint.Demo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AdmintWeb.Demo.Endpoint.config_change(changed, removed)
    :ok
  end
end
