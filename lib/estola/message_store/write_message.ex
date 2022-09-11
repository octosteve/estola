defmodule Estola.MessageStore.WriteMessage do
  use Ecto.Schema
  import Ecto.Changeset

  @field_order [:id, :stream_name, :type, :data, :metadata, :expected_version]
  #  @primary_key {:id, :binary_id, autogenrate: false}
  @function_name :write_message

  embedded_schema do
    field(:stream_name, :string)
    field(:type, :string)
    field(:data, :map)
    field(:metadata, :map)
    field(:expected_version, :integer)
  end

  def new(params) do
    %__MODULE__{}
    |> changeset(params)
    |> apply_action(:initialize)
  end

  def changeset(message, params \\ %{}) do
    message
    |> cast(params, [:id, :stream_name, :type, :data, :metadata, :expected_version])
    |> handle_empty_id
    |> validate_required([:stream_name, :type, :data])
    |> validate_valid_id
    |> validate_valid_stream_name
  end

  def handle_empty_id(changeset) do
    if get_change(changeset, :id) do
      changeset
    else
      put_change(changeset, :id, Ecto.UUID.generate())
    end
  end

  def validate_valid_id(changeset) do
    case changeset
         |> get_change(:id)
         |> Ecto.UUID.cast() do
      :error ->
        changeset
        |> add_error(:id, "invalid_uuid")

      _ ->
        changeset
    end
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

  def cast_to_named_parameter(type), do: type |> to_string
end
