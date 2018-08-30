defmodule Fabion.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fabion,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [
        "test.watch": :test,
        "test.drop": :test,
        "test.setup": :test,
        "test.reset": :test
      ],
      aliases: aliases(),
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
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # sugar
      {:pipe_to, "~> 0.2.0"},
      {:shorter_maps, "~> 2.2"},
      {:jqish, "~> 0.1.2", only: :test},

      # Phoenix Framewokr
      {:phoenix, "~> 1.3.3"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},

      # Graphql
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4"},
      {:absinthe_relay, "~> 1.4"},
      {:absinthe_phoenix, "~> 1.4"},
      {:absinthe_ecto, "~> 0.1.3"},

      # Configs and envs controller
      {:dotenv, "~> 3.0"},
      {:confex, "~> 3.3", override: true},

      # General libs
      {:google_api_cloud_build,
       github: "nuxlli/elixir-google-api",
       branch: "update_cloud_build",
       sparse: "clients/cloud_build"},
      {:goth, "~> 0.10.0"},
      {:httpoison, "~> 1.2"},
      {:slugify, "~> 1.1"},
      {:timex, "~> 3.3"},

      # Test and developer
      {:mix_test_watch, "~> 0.8", only: :test, runtime: false},
      {:faker, "~> 0.10.0", only: [:dev, :test]},
      {:ex_machina, "~> 2.2", only: [:dev, :test]},
      {:exvcr, "~> 0.10", only: :test},
      {:mox, "~> 0.4.0", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.seeds": ["run priv/repo/seeds.exs"],
      "ecto.redo": ["ecto.rollback -n 1", "ecto.migrate"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seeds"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],

      # Release
      "release.prod": ["compile", "phx.digest", "release"],

      # Test options
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "test.drop": ["ecto.drop"],
      "test.setup": ["ecto.create --quite", "ecto.migrate"],
      "test.reset": ["test.drop", "test.setup"],
      "test.skip": ["test.watch --exclude skip:true"],
      "test.only": ["test.watch --only runnable:true"]
    ]
  end
end
