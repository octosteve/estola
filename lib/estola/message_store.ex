defmodule Estola.MessageStore do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def write_message(message) do
    GenServer.call(__MODULE__, {:write_message, message})
  end

  def get_stream_messages(message) do
    GenServer.call(__MODULE__, {:get_stream_messages, message})
  end

  def get_category_messages(message) do
    GenServer.call(__MODULE__, {:get_category_messages, message})
  end

  def get_last_stream_message(message) do
    GenServer.call(__MODULE__, {:get_last_stream_message, message})
  end

  def stream_version(message) do
    GenServer.call(__MODULE__, {:stream_version, message})
  end

  def stream_id(message) do
    GenServer.call(__MODULE__, {:stream_id, message})
  end

  def stream_cardinal_id(message) do
    GenServer.call(__MODULE__, {:stream_cardinal_id, message})
  end

  def category_from_stream(message) do
    GenServer.call(__MODULE__, {:category_from_stream, message})
  end

  def init(:ok) do
    _set_command = "SET search_path TO #{config()[:database]},public;"

    {:ok, pid} = Postgrex.start_link(config())

    {:ok, %{pid: pid}}
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

  defp config do
    Application.get_env(:estola, :message_store)
  end
end
