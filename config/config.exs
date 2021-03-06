# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :numo, Numo.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "Ms49UCVxJBSU+0LkPGAuzGiJfHBgHVeaeWGa89faOFsGL/PEoJajf6nbzMSe+rRb",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Numo.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures the Consumers
config :numo, Consumers,
  consumers: [{Consumer.Json,
                %{broker: "amqp://guest:guest@192.168.99.100",
                  in_queue: "numo",
                  out_exchange: "out",
                  out_throttle: {"output", 50000}}}]

config :numo, ConCache,
  ttl: :timer.minutes(30),
  ttl_check: :timer.minutes(1)

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
