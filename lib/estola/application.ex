defmodule Estola.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  @pool_size Application.get_env(:estola, :message_store)[:pool_size]

  @impl true
  def start(_type, _args) do
    children = [
      :poolboy.child_spec(:worker, poolboy_config())
    ]

    opts = [strategy: :one_for_one, name: Estola.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp poolboy_config do
    [
      name: {:local, :message_store},
      worker_module: Estola.MessageStore,
      size: @pool_size
    ]
  end
end
