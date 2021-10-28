defmodule Estola.MessageStore.MessageTest do
  use ExUnit.Case
  alias Estola.MessageStore.Message

  test "propery converts row data" do
    message =
      Message.new([
        {"1cf0eacb-696e-429b-99eb-6a7b57bfcfc5", "hello-123", "MyType", 5, 6,
         "{\"data\": \"value\"}", "{\"correlationStream\": \"beef\"}",
         ~N[2021-10-28 04:12:19.371721]}
      ])

    assert message.id == "1cf0eacb-696e-429b-99eb-6a7b57bfcfc5"
    assert message.stream_name == "hello-123"
    assert message.type == "MyType"
    assert message.position == 5
    assert message.global_position == 6
    assert message.data["data"] == "value"
    assert message.metadata["correlationStream"] == "beef"
    assert message.time == ~N[2021-10-28 04:12:19.371721]
  end

  test "works with empty metadat" do
    message =
      Message.new([
        {"1cf0eacb-696e-429b-99eb-6a7b57bfcfc5", "hello-123", "MyType", 5, 6,
         "{\"data\": \"value\"}", nil, ~N[2021-10-28 04:12:19.371721]}
      ])

    assert message.id == "1cf0eacb-696e-429b-99eb-6a7b57bfcfc5"
    assert message.stream_name == "hello-123"
    assert message.type == "MyType"
    assert message.position == 5
    assert message.global_position == 6
    assert message.data["data"] == "value"
    assert message.metadata == %{}
    assert message.time == ~N[2021-10-28 04:12:19.371721]
  end
end
