# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :be_exercise,
  ecto_repos: [BeExercise.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :be_exercise, BeExerciseWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: BeExerciseWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: BeExercise.PubSub,
  live_view: [signing_salt: "hBsN9Drq"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :flop, repo: BeExercise.Repo

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
