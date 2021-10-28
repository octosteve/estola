defmodule Estola.MessageStore.Message do
  defstruct [:id, :stream_name, :type, :position, :global_position, :data, :metadata, :time]

  def new([{id, stream_name, type, position, global_position, data, metadata, time}]) do
    struct!(__MODULE__,
      id: id,
      stream_name: stream_name,
      type: type,
      position: position,
      global_position: global_position,
      data: data,
      metadata: metadata,
      time: time
    )
  end
end
