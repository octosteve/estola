defmodule Estola.MessageStore.GetCategoryMessagesTest do
  use ExUnit.Case
  alias Estola.MessageStore.GetCategoryMessages

  test "validates category name is present is valid" do
    {:error, changeset} = GetCategoryMessages.new(%{})
    assert changeset.errors[:category] == {"can't be blank", [{:validation, :required}]}
  end

  test "uses correct defaults" do
    {:ok, message} = GetCategoryMessages.new(%{category: "foo"})
    assert message.position == 1
    assert message.batch_size == 1000
    assert message.correlation |> is_nil
    assert message.consumer_group_member |> is_nil
    assert message.consumer_group_size |> is_nil
    assert message.condition |> is_nil
  end

  test "properly converts to sql" do
    {:ok, message} = GetCategoryMessages.new(%{category: "foo"})

    assert message |> GetCategoryMessages.to_sql() ==
             ~s[SELECT get_category_messages(category => 'foo', "position" => 1, batch_size => 1000, correlation => NULL, consumer_group_member => NULL, consumer_group_size => NULL, condition => NULL);]
  end
end
