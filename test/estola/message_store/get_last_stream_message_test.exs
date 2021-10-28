defmodule Estola.MessageStore.GetLastStreamMessageTest do
  use ExUnit.Case
  alias Estola.MessageStore.GetLastStreamMessage

  test "validates stream_name is valid" do
    {:error, changeset} = GetLastStreamMessage.new(%{})
    assert changeset.errors[:stream_name] == {"can't be blank", [{:validation, :required}]}
  end

  test "properly converts to sql" do
    {:ok, message} = GetLastStreamMessage.new(%{stream_name: "stream-123"})

    assert message |> GetLastStreamMessage.to_sql() ==
             ~s[SELECT get_last_stream_message(stream_name => 'stream-123');]
  end
end
