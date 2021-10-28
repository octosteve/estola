defmodule Estola.MessageStore.GetStreamMessages do
  use Ecto.Schema
  import Ecto.Changeset

  @field_order ~w[stream_name position batch_size condition]a
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
    |> cast(params, ~w[stream_name position batch_size condition]a)
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
          IO.inspect(field, label: "Fierd")
          value = Map.get(struct, field)
          acc <> cast_field(field, value) <> ", "
      end

    fields =
      fields
      |> String.trim_trailing(", ")

    "SELECT #{@function_name}(#{fields});"
  end

  def cast_field(:position, nil) do
    "#{cast_to_named_parameter(:position)} => NULL"
  end

  def cast_field(type, nil) do
    "#{cast_to_named_parameter(type)} => NULL"
  end

  def cast_field(type, field) when is_map(field),
    do: "#{cast_to_named_parameter(type)} => '#{field |> Jason.encode!()}'"

  def cast_field(type, field) do
    casted =
      case __schema__(:type, type) do
        :integer -> field |> to_string
        :binary_id -> "'#{field}'"
        :string -> "'#{field}'"
      end

    "#{cast_to_named_parameter(type)} => #{casted}"
  end

  def cast_to_named_parameter(:position), do: "\"position\""
  def cast_to_named_parameter(type), do: type |> to_string
end
