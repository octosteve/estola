import Config

config :estola, :message_store,
  username: "postgres",
  password: "postgres",
  database: "message_store",
  hostname: "localhost",
  pool_size: 5
