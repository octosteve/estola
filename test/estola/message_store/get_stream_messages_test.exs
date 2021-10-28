defmodule Estola.MessageStore.GetStreamMessagesTest do
  use ExUnit.Case
  alias Estola.MessageStore.GetStreamMessages

  test "validates stream_name is valid" do
    {:error, changeset} = GetStreamMessages.new(%{stream_name: "womp"})
    assert changeset.errors[:stream_name] == {"invalid_stream_name", []}
  end

  test "uses correct defaults" do
    {:ok, message} = GetStreamMessages.new(%{stream_name: "stream-123"})
    assert message.position == 0
    assert message.batch_size == 1000
  end

  test "properly converts to sql" do
    {:ok, message} = GetStreamMessages.new(%{stream_name: "stream-123"})

    assert message |> GetStreamMessages.to_sql() ==
             "SELECT get_stream_messages('stream-123', 0, 1000, NULL);"
  end
end
