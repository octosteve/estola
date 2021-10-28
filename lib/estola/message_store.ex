defmodule Estola.MessageStore do
  use GenServer
  @config Application.get_env(:estola, :message_store)

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, pid} = Postgrex.start_link(config)
    {:ok, %{postgrex_pid: pid},{:continue, :configure}}
  end

  def handle_continue(:configure, state) do 
    Postgrex.query!(state.postgrex_pid, "SET search_path TO message_store,public;",[])
    {:noreply, state
  end
end
