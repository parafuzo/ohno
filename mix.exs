defmodule Fabion.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fabion,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      preferred_cli_env: [
        "test.watch": :test,
      ],
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Fabion.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Phoenix Framewokr
      {:phoenix, "~> 1.3.3"},
      {:phoenix_pubsub, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},

      # Configs and envs controller
      {:dotenv, "~> 3.0"},
      {:confex, "~> 3.3", override: true},

      # General libs
      {:google_api_cloud_build, github: "nuxlli/elixir-google-api", branch: "update_cloud_build", sparse: "clients/cloud_build"},
      {:goth, "~> 0.10.0"},
      {:httpoison, "~> 1.2"},
      {:shorter_maps, "~> 2.2"},

      # Test and developer
      {:mix_test_watch, "~> 0.8", only: :test, runtime: false},
      {:exvcr, "~> 0.10", only: :test},
      {:mox, "~> 0.4.0", only: :test},
    ]
  end
end
