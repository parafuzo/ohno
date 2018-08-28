# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

Code.eval_file("./dotenv.exs", __DIR__)

# Configures the endpoint
config :fabion, FabionWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Gvh/uXugFAW3EHBzviZTuXF5alfa92hHbyrib5PUEpvgW1Ta92VILdisEw6e9TDl",
  render_errors: [view: FabionWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Fabion.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :goth,
  config_module: Fabion.GothConfig,
  json_env: {:system, {Base, :decode64, []}, "GOTH_JSON_BASE64"}

config :fabion, Fabion.Github,
  auth_token: {:system, :string, "FABION_GITHUB_TOKE"}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
