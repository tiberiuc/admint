defmodule Admint.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      description: "Admint - an easy admin generator using phoenix liveview",
      app: :admint,
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      # compilers: [] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  defp package do
    [
      maintainers: [" Tibi Craciun "],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/tiberiuc/admint"}
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    apps = [
      # mod: {Admint.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]

    apps
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # {:phoenix_view, "~> 2.0"},
      {:phoenix, "~> 1.7"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.20"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_html, "~> 3.3"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.0"},
      {:elixir_uuid, "~> 1.2"},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:ex_doc, "~> 0.21", only: :docs, runtime: false}
    ]
  end

  defp docs do
    [
      main: "Admint",
      source_ref: "v#{@version}",
      source_url: "https://github.com/tiberiuc/admint",
      extra_section: "GUIDES",
      extras: extras()
      # nest_modules_by_prefix: [Phoenix.LiveDashboard]
    ]
  end

  defp extras do
    [
      # "guides/ecto_stats.md",
      # "guides/metrics.md",
      # "guides/metrics_history.md",
      # "guides/os_mon.md",
      # "guides/request_logger.md"
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "js.deps"],
      "js.deps": ["cmd npm install --prefix assets"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"],
      "assets.clean": ["cmd rm -rf priv/static"],
      "build.hex": ["assets.clean", "js.deps", "assets.deploy", "hex.build"],
      test: [
        # "ecto.create --quiet", "ecto.migrate --quiet", 
        "test"
      ]
    ]
  end
end
