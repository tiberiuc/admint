defmodule Admint.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      # Admint.Test.Repo,
      # Start the Telemetry supervisor
      # AdmintWeb.Telemetry,
      # Start the PubSub system
      # {Phoenix.PubSub, name: Admint.PubSub},
      # Start the Endpoint (http/https)
      # AdmintWeb.Endpoint
      # Start a worker by calling: Admint.Worker.start_link(arg)
      # {Admint.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Admint.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(_changed, _new, _removed) do
    # AdmintWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
