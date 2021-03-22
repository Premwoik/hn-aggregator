# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :hn_aggregator, :aggregation_server, HnAggregator.AggregationServer
config :hn_aggregator, :hn_api, HnAggregator.HackerNewsClient
config :hn_aggregator, :broadcast_handler, HnAggregatorWeb.StoryChannel
config :hn_aggregator, :hn_api_url, "https://hacker-news.firebaseio.com/v0"
config :hn_aggregator, :fetcher, refresh_interval: 5 * 60_000

# Configures the endpoint
config :hn_aggregator, HnAggregatorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lT6CrOUO+3rKJMlYioQaX+Ni15XrGeJhtgIQWFTDpchbEfG1siHE7IG/VtaIY7SS",
  render_errors: [view: HnAggregatorWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: HnAggregator.PubSub,
  live_view: [signing_salt: "D2c0WeOx"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
