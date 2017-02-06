defmodule BasicSupervisorTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  doctest BasicSupervisor
  #unit test for supervisor with startegy one_for_one
  setup_all do
    {:ok, super_id} = BasicSupervisor.start_link :one_for_one
    children_list = Supervisor.which_children(super_id)
    {:ok, super_id: super_id, children: children_list}
  end

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "Supervisor process started", %{super_id: super_id} do
    assert Process.alive?(super_id)
  end

  test "4 processes were started from Genserver", %{children: children_list} do
    assert length( children_list ) == 4
  end

  test "When process is down, it is restarted by supervisor", %{super_id: super_id, children: children_list} do
    [_, _, _, one] = children_list
    {_, one_pid, _, _} = one
    GenServer.stop(one_pid)
    new_children_list = Supervisor.which_children(super_id)
    [_, _, _, new_one] = new_children_list
    {_, new_one_pid, _, _} = new_one
    x = capture_io(fn -> IO.inspect one_pid  end)
    y = capture_io(fn -> IO.inspect new_one_pid  end)

    assert (not Process.alive?(one_pid))
    assert length( new_children_list ) == 4
    assert x != y
  end

  test "Supervisor with one_for_all stratey when one process stop all processes are restarted" do
      {:ok, super_id} = BasicSupervisor.start_link :one_for_all
      children_list = Supervisor.which_children(super_id)
      [_,_, _, one] = children_list
      {_, one_pid, _, _} = one
      GenServer.stop(one_pid)
      new_children_list = Supervisor.which_children(super_id)
      assert (not Process.alive?(one_pid))
      assert children_list != new_children_list
  end

  test "Supervisor with rest_for_one stratey will restart only processes that are below below the process that stopped(including the stopped one)" do
      {:ok, super_id} = BasicSupervisor.start_link :rest_for_one
      children_list = Supervisor.which_children(super_id)
      [four_pid, three_pid, two_pid, one_pid] = Enum.map children_list, fn {_, pid, _, _} -> pid end
      GenServer.stop(two_pid)
      new_children_list = Supervisor.which_children(super_id)
      assert Enum.any?([two_pid, three_pid, four_pid], fn(x) -> Process.alive?(x) != true end)
      assert  Process.alive? one_pid
  end

  test "Supervisor with simple_one_for_one stratey only one worlder to be define" do
      {:ok, super_id} = BasicSupervisor.start_simple_link
      assert Supervisor.which_children(super_id) == []
      Supervisor.start_child(super_id, [])
      assert length(Supervisor.which_children(super_id)) == 1
      Supervisor.start_child(super_id, [])
      children = Supervisor.which_children(super_id)
      assert length(children) == 2
      [child_one, child_two] = children

      #assure that it is same type of worker
      assert (elem(child_one, 3) == elem(child_two, 3))
  end
end
