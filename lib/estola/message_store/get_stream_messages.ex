defmodule Estola.MessageStore.GetStreamMessages do
  use Ecto.Schema
  import Ecto.Changeset

  @field_order [:stream_name, :position, :batch_size, :condition]
  @primary_key false
  @function_name :get_stream_messages

  embedded_schema do
    field(:stream_name, :string)
    field(:position, :integer, default: 0)
    field(:batch_size, :integer, default: 1000)
    field(:condition, :string)
  end

  def new(params) do
    %__MODULE__{}
    |> changeset(params)
    |> apply_action(:initialize)
  end

  def changeset(message, params \\ %{}) do
    message
    |> cast(params, [:stream_name, :position, :batch_size, :condition])
    |> validate_required([:stream_name])
    |> validate_valid_stream_name
  end

  def validate_valid_stream_name(changeset) do
    if changeset |> get_change(:stream_name, "") |> String.contains?("-") do
      changeset
    else
      changeset
      |> add_error(:stream_name, "invalid_stream_name")
    end
  end

  def to_sql(%__MODULE__{} = struct) do
    fields =
      for field <- @field_order, reduce: "" do
        acc ->
          value = Map.get(struct, field)
          acc <> cast_field(field, value) <> ", "
      end

    fields =
      fields
      |> String.trim_trailing(", ")

    "SELECT #{@function_name}(#{fields});"
  end

  def cast_field(_type, nil), do: "NULL"
  def cast_field(_type, field) when is_map(field), do: "'#{field |> Jason.encode!()}'"

  def cast_field(type, field) do
    case __schema__(:type, type) do
      :integer -> field |> to_string
      :binary_id -> "'#{field}'"
      :string -> "'#{field}'"
    end
  end
end
