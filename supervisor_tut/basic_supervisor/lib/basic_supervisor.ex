defmodule BasicSupervisor do
    use Supervisor
    # strategy options: one_for_one, one_for_all
    def start_link(strategy) when is_atom(strategy) do
        Supervisor.start_link(__MODULE__, [strategy])
    end

    def start_simple_link do
        Supervisor.start_link(__MODULE__, {:simple_one_for_one})
    end

    def init({:simple_one_for_one}) do
      children = [
          worker(BasicOne, [])
      ]
      supervise(children, strategy: :simple_one_for_one )
    end

    def init([strategy|_]) do
        children = [
            worker(BasicOne, []),
            worker(BasicTwo, []),
            worker(BasicThree, []),
            worker(BasicFour, [])
        ]

        supervise(children, strategy: strategy )
    end
end
