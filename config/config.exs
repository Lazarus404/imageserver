# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :imageserver,
  ecto_repos: [Imageserver.Repo],
  trello_board: "Imageserver",
  trello_card: "Tasks"

# Configures the endpoint
config :imageserver, Imageserver.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ypem6rKSQ8hUIpR88x1dQL779lBMdVcqopEIyNJ3rqbj9LOJBON4iKLs1wqGfwZt",
  render_errors: [view: Imageserver.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Imageserver.PubSub,
           adapter: Phoenix.PubSub.PG2],
  max_upload: System.get_env("IMAGESERVER_MAX_UPLOAD") || 5_242_880 # maximum 5mb upload

config :arc,
  bucket: "ls-test.touchtech"

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]

config :ex_trello, :oauth, [
  consumer_key:    System.get_env("TRELLO_KEY"),
  consumer_secret: System.get_env("TRELLO_SECRET"),
  token:           "2ef5a4b3d9e0a7f5422fa6d39b07f63dea7a566f25546606249b3db3910d66fa",
  token_secret:    "2d0e30e33bd9071e8a48325c4861f00c"
]


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
