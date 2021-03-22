use Mix.Config

config :hn_aggregator, :aggregation_server, HnAggregator.AggregationServer
config :hn_aggregator, :broadcast_handler, HnAggregatorWeb.StoryChannel
config :hn_aggregator, :hn_api, HnAggregator.HackerNewsTestClient
config :hn_aggregator, :hn_api_url, "http://localhost:43443"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hn_aggregator, HnAggregatorWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :debug
