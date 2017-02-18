defmodule TodoEtsTest do
  use ExUnit.Case
  doctest TodoEts

  setup_all do
    first_table = TodoEts.start_link
    TodoEts.new(:shopping)
    {:ok, table: first_table}
  end

  test "ETS todo table created at start of gen server." do
    assert :ets.all |> Enum.member?(:todos)
  end

  test "ETS new task" do
    assert TodoEts.find(:random)
    assert TodoEts.new(:shopping) == :already_exist
  end

  test "ETS find method" do
     assert TodoEts.find(:shopping)
     assert TodoEts.find(:random) == :error
  end

  test "ETS add todo item" do
    assert {:added, _items } = TodoEts.add(:shopping, "milk")
    assert {:error, :no_list_found} = TodoEts.add(:random, "milk") 
  end
end
