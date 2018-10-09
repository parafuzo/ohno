use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ohno, OhnoWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :ohno, Ohno.Sources,
  adapter: Ohno.MockSourcesAdapter

config :ohno, Ohno.CloudBuild,
  adapter: Ohno.CloudBuild.MockAdapter

config :ohno, Ohno.Enqueuer, [
  adapter: GenQueue.Adapters.MockJob
]

config :ohno, Ohno.Sources.Repository,
  fixture: {:system, {Base, :decode64, []}, "FIXTURES_OHNO_REPOSITORY"}

config :mix_test_watch,
  clear: true,
  extra_extensions: ["graphql"]

# Configure your database
config :ohno, Ohno.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ohno_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
