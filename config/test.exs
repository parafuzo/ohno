use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fabion, FabionWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :fabion, Fabion.Sources,
  adapter: Fabion.MockSourcesAdapter

config :fabion, Fabion.CloudBuild,
  adapter: Fabion.CloudBuild.MockAdapter

config :fabion, Fabion.Enqueuer, [
  adapter: GenQueue.Adapters.MockJob
]

config :fabion, Fabion.Sources.Repository,
  fixture: {:system, {Base, :decode64, []}, "FIXTURES_FABION_REPOSITORY"}

config :mix_test_watch,
  clear: true,
  extra_extensions: ["graphql"]

# Configure your database
config :fabion, Fabion.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "fabion_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
