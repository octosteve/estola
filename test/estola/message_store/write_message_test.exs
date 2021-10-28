defmodule Estola.MessageStore.WriteMessageTest do
  use ExUnit.Case
  alias Estola.MessageStore.WriteMessage

  test "validates id is valid" do
    {:error, changeset} = WriteMessage.new(%{id: "womp"})
    assert changeset.errors[:id] == {"invalid_uuid", []}
  end

  test "ensures stream_name, type, and data are provided" do
    {:error, changeset} = WriteMessage.new(%{})
    assert changeset.errors[:stream_name] == {"invalid_stream_name", []}
    assert changeset.errors[:type] == {"can't be blank", [{:validation, :required}]}
    assert changeset.errors[:data] == {"can't be blank", [{:validation, :required}]}
  end

  test "data is properly casted" do
    {:ok, message} =
      WriteMessage.new(%{
        id: Ecto.UUID.generate(),
        stream_name: "test-12312",
        type: "test",
        data: %{foo: "bar"},
        metadata: %{baz: "qux"},
        expected_version: 1
      })

    assert message.data == %{foo: "bar"}
    assert message.metadata == %{baz: "qux"}
  end

  # Modeled after https://github.com/message-db/message-db/blob/58cc491f8b5da3d50dbcec36d652d144070018a3/database/functions/is-category.sql#L7
  test "enforces stream name" do
    {:error, changeset} =
      WriteMessage.new(%{
        id: Ecto.UUID.generate(),
        stream_name: "test",
        type: "test",
        data: %{foo: "bar"},
        metadata: %{baz: "qux"},
        expected_version: 1
      })

    assert changeset.errors[:stream_name] == {"invalid_stream_name", []}
  end

  test "converts struct to SQL command" do
    uuid = Ecto.UUID.generate()

    {:ok, message} =
      WriteMessage.new(%{
        id: uuid,
        stream_name: "someStream-123",
        type: "SomeMessageType",
        data: %{"someAttribute" => "some value"},
        metadata: %{"metadataAttribute" => "some meta data value"},
        expected_version: 1
      })

    assert message |> WriteMessage.to_sql() ==
             ~s[SELECT write_message('#{uuid}', 'someStream-123', 'SomeMessageType', '{"someAttribute":"some value"}', '{"metadataAttribute":"some meta data value"}', 1);]
  end

  test "sends in correct defaults when not provided" do
    uuid = Ecto.UUID.generate()

    {:ok, message} =
      WriteMessage.new(%{
        id: uuid,
        stream_name: "someStream-123",
        type: "SomeMessageType",
        data: %{"someAttribute" => "some value"}
      })

    assert message |> WriteMessage.to_sql() ==
             ~s[SELECT write_message('#{uuid}', 'someStream-123', 'SomeMessageType', '{"someAttribute":"some value"}', NULL, NULL);]
  end
end
