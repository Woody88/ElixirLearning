defmodule BasicTwo do
  use GenServer

  def start_link do
    IO.puts "#{__MODULE__} is starting"
    GenServer.start_link(__MODULE__, [])
  end
end
