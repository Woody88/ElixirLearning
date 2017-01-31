defmodule StatefulMap do
    def start do
        spawn(fn -> loop(%{}) end)
    end
    
    def loop(current) do
        new = receive do 
            message -> process(current, message)
        end
        loop(new)
    end
    
    def put(pid, key, value), do: send(pid, {:put, key, value})
    def put(pid, map) when is_map(map), do: send(pid,{:put, map})
    def put(pid, keyword_list) when is_list(keyword_list) do
        if Keyword.keyword?(keyword_list) do
            Enum.map(keyword_list, fn{key, value} -> 
                put(pid, key, value)
            end)
        else
            raise "Invalid list. Not a Keyword List type." 
        end   
    end

    def get(pid, key) do
        send(pid, {:get, key, self()})
        
        receive do 
            {:response, value} -> value
        end
    end
    
    def get(pid) do
        send(pid, {:get_map, self()})
        
        receive do
            {:response, value} -> value
        end
    end
    
    defp process(current, {:put, key, value}), do: Map.put(current, key, value)
    defp process(current, {:put, map}) when is_map(map), do: Map.merge(current,map)
    defp process(current, {:get, key, caller}) do
        send(caller, {:response, Map.get(current, key)})
        current
    end
    defp process(current, {:get_map, caller})  do 
        send(caller, {:response, current})
        current
    end
end

