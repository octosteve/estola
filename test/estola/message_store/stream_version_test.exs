defmodule Estola.MessageStore.StreamVersionTest do
  use ExUnit.Case
  alias Estola.MessageStore.StreamVersion

  test "validates stream_name is valid" do
    {:error, changeset} = StreamVersion.new(%{})
    assert changeset.errors[:stream_name] == {"can't be blank", [{:validation, :required}]}
  end

  test "properly converts to sql" do
    {:ok, message} = StreamVersion.new(%{stream_name: "stream-123"})

    assert message |> StreamVersion.to_sql() ==
             ~s[SELECT stream_version(stream_name => 'stream-123');]
  end
end
