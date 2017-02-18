defmodule TodoEts do
  use GenServer, async: true

  def start_link, do: GenServer.start(__MODULE__, :ok, name: __MODULE__)

  def init(:ok), do: {:ok, :ets.new(:todos, [:named_table, :public]) }

  def new(name) when is_atom(name), do: GenServer.call(__MODULE__, {:new, name})

  def add(name, item) when is_binary(item), do: GenServer.call(__MODULE__, {:add, name, item})

  def find(name) when is_atom(name) do
    case :ets.lookup(:todos,name) do
      [{^name, items}] -> {:ok, items}
      [] -> :error
    end
  end

  def handle_call({:new, name}, _from, table) do
    case find(name) do
      {:ok, _} -> {:reply, :already_exist, table}
      :error ->
        :ets.insert(table, {name, []})
        {:reply, [], table}
    end
  end

  def handle_call({:add, name, item}, _from, table) do
    case find(name) do
      {:ok, items} ->
        :ets.insert(:todos, {name,[item]++items})
        {:reply, {:added, items}, table}
      :error ->
        {:reply, {:error, :no_list_found}, table}
    end
  end

end
