defmodule Estola.MessageStore do
  use GenServer
  @config Application.get_env(:estola, :message_store)

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def write_message(message) do
    GenServer.call(__MODULE__, {:write_message, message})
  end

  def get_stream_messages(message) do
    GenServer.call(__MODULE__, {:get_stream_messages, message})
  end

  def init(:ok) do
    {:ok, pid} = Postgrex.start_link(@config)
    {:ok, %{pid: pid}, {:continue, :configure}}
  end

  def handle_continue(:configure, state) do
    Postgrex.query!(state.pid, "SET search_path TO #{@config[:database]},public;", [])
    {:noreply, state}
  end

  def handle_call({:write_message, message}, _reply, state) do
    case message |> Estola.MessageStore.WriteMessage.new() do
      {:ok, message_struct} ->
        Postgrex.query!(
          state.pid,
          message_struct
          |> Estola.MessageStore.WriteMessage.to_sql(),
          []
        )

        {:reply, :success, state}

      {:error, changeset} ->
        {:reply, changeset, state}
    end
  end

  def handle_call({:get_stream_messages, message}, _reply, state) do
    case message |> Estola.MessageStore.GetStreamMessages.new() do
      {:ok, message_struct} ->
        result =
          Postgrex.query!(
            state.pid,
            message_struct
            |> Estola.MessageStore.GetStreamMessages.to_sql(),
            []
          ).rows
          |> Enum.map(&Estola.MessageStore.Message.new/1)

        {:reply, result, state}

      {:error, changeset} ->
        {:reply, changeset, state}
    end
  end
end
