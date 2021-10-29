# Estola

This app wraps calls to the MessageDB event store.

## Available functions
After adding this to your application, you can call the following functions from the `Estola.MessageStore` module.

### write_message

```elixir
Estola.MessageStore.write_message(%{
  id: Ecto.UUID.generate(),
  stream_name: "hello-456",
  type: "MyType",
  data: %{data: "value"},
  metadata: %{correlationStream: "stevenStream"}
})
# :success
```

The arguments match arguments listed [here](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#write-a-message). As of this writing, there is no way to do batched messages.


### get_stream_messages

```elixir
Estola.MessageStore.get_stream_messages(%{stream_name: "hello-123"})
# [
#   %Estola.MessageStore.Message{
#     data: %{"data" => "value"},
#     global_position: 1,
#     id: "f900cab5-a4b1-49d9-9c51-2f712e3a6602",
#     metadata: %{},
#     position: 0,
#     stream_name: "hello-123",
#     time: ~N[2021-10-28 04:09:15.540016],
#     type: "MyType"
#   },...
# ]
```

The arguments match arguments listed [here](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#get-messages-from-a-stream).

### get_category_messages

```elixir
Estola.MessageStore.get_category_messages(%{category: "hello"})
# [
#   %Estola.MessageStore.Message{
#     data: %{"data" => "value"},
#     global_position: 1,
#     id: "f900cab5-a4b1-49d9-9c51-2f712e3a6602",
#     metadata: %{},
#     position: 0,
#     stream_name: "hello-123",
#     time: ~N[2021-10-28 04:09:15.540016],
#     type: "MyType"
#   },...
# ]
```


The arguments match arguments listed [here](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#get-messages-from-a-category).


### get_last_stream_message

```elixir

Estola.MessageStore.get_last_stream_message(%{stream_name: "hello-456"})
# %Estola.MessageStore.Message{
#   data: %{"data" => "value"},
#   global_position: 13,
#   id: "45fdd1ec-9f9c-4849-ab89-c9a57e150cb9",
#   metadata: %{"correlationStream" => "stevenStream"},
#   position: 6,
#   stream_name: "hello-456",
#   time: ~N[2021-10-28 16:41:33.069423],
#   type: "MyType"
# }
```


The arguments match arguments listed [here](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#get-last-message-from-a-stream).

### stream_version(message)

```elixir
Estola.MessageStore.stream_version(%{stream_name: "hello-456"})
# 6
```

The arguments match arguments listed [here](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#get-stream-version-from-a-stream). This function returns a `Estola.MessageStore.Message` or `nil`.

### stream_id(message)

```elixir
Estola.MessageStore.stream_id(%{stream_name: "hello-456"})
# "456"
```
The arguments match arguments listed [here](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#get-the-id-from-a-stream-name).

### stream_cardinal_id(message)

```elixir
Estola.MessageStore.stream_cardinal_id(%{stream_name: "hello-456+command"})
# "456"
```
The arguments match arguments listed [here](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#get-the-cardinal-id-from-a-stream-name).

### category_from_stream(message)

``` elixir
Estola.MessageStore.category_from_stream(%{stream_name: "hello-456"})
# "hello"
```

The arguments match arguments listed [here](http://docs.eventide-project.org/user-guide/message-db/server-functions.html#get-the-category-from-a-stream-name).
