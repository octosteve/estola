defmodule Estola.MessageStore do
  use GenServer
  @config Application.get_env(:estola, :message_store)

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def write_message(pid, message) do
    GenServer.call(pid, {:write_message, message})
  end

  def get_stream_messages(pid, message) do
    GenServer.call(pid, {:get_stream_messages, message})
  end

  def get_category_messages(pid, message) do
    GenServer.call(pid, {:get_category_messages, message})
  end

  def get_last_stream_message(pid, message) do
    GenServer.call(pid, {:get_last_stream_message, message})
  end

  def stream_version(pid, message) do
    GenServer.call(pid, {:stream_version, message})
  end

  def stream_id(pid, message) do
    GenServer.call(pid, {:stream_id, message})
  end

  def stream_cardinal_id(pid, message) do
    GenServer.call(pid, {:stream_cardinal_id, message})
  end

  def category_from_stream(pid, message) do
    GenServer.call(pid, {:category_from_stream, message})
  end

  def init(:ok) do
    {:ok, pid} = Postgrex.start_link(@config)
    {:ok, %{pid: pid}, {:continue, :configure}}
  end

  def handle_continue(:configure, state) do
    set_command = "SET search_path TO #{@config[:database]},public;"
    Postgrex.query!(state.pid, set_command, [])
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

  def handle_call({:get_category_messages, message}, _reply, state) do
    case message |> Estola.MessageStore.GetCategoryMessages.new() do
      {:ok, message_struct} ->
        result =
          Postgrex.query!(
            state.pid,
            message_struct
            |> Estola.MessageStore.GetCategoryMessages.to_sql(),
            []
          ).rows
          |> Enum.map(&Estola.MessageStore.Message.new/1)

        {:reply, result, state}

      {:error, changeset} ->
        {:reply, changeset, state}
    end
  end

  def handle_call({:get_last_stream_message, message}, _reply, state) do
    case message |> Estola.MessageStore.GetLastStreamMessage.new() do
      {:ok, message_struct} ->
        result =
          Postgrex.query!(
            state.pid,
            message_struct
            |> Estola.MessageStore.GetLastStreamMessage.to_sql(),
            []
          ).rows
          |> Enum.map(&Estola.MessageStore.Message.new/1)
          |> List.first()

        {:reply, result, state}

      {:error, changeset} ->
        {:reply, changeset, state}
    end
  end

  def handle_call({:stream_version, message}, _reply, state) do
    case message |> Estola.MessageStore.StreamVersion.new() do
      {:ok, message_struct} ->
        [[result]] =
          Postgrex.query!(
            state.pid,
            message_struct
            |> Estola.MessageStore.StreamVersion.to_sql(),
            []
          ).rows

        {:reply, result, state}

      {:error, changeset} ->
        {:reply, changeset, state}
    end
  end

  def handle_call({:stream_id, message}, _reply, state) do
    case message |> Estola.MessageStore.StreamId.new() do
      {:ok, message_struct} ->
        [[result]] =
          Postgrex.query!(
            state.pid,
            message_struct
            |> Estola.MessageStore.StreamId.to_sql(),
            []
          ).rows

        {:reply, result, state}

      {:error, changeset} ->
        {:reply, changeset, state}
    end
  end

  def handle_call({:stream_cardinal_id, message}, _reply, state) do
    case message |> Estola.MessageStore.StreamCardinalId.new() do
      {:ok, message_struct} ->
        [[result]] =
          Postgrex.query!(
            state.pid,
            message_struct
            |> Estola.MessageStore.StreamCardinalId.to_sql(),
            []
          ).rows

        {:reply, result, state}

      {:error, changeset} ->
        {:reply, changeset, state}
    end
  end

  def handle_call({:category_from_stream, message}, _reply, state) do
    case message |> Estola.MessageStore.CategoryFromStream.new() do
      {:ok, message_struct} ->
        [[result]] =
          Postgrex.query!(
            state.pid,
            message_struct
            |> Estola.MessageStore.CategoryFromStream.to_sql(),
            []
          ).rows

        {:reply, result, state}

      {:error, changeset} ->
        {:reply, changeset, state}
    end
  end
end
