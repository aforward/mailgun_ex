defmodule MailgunEx.Simulate do
  use GenServer
  use FnExpr
  alias GenServer, as: GS
  alias MailgunEx.Simulate, as: W

  ### Public API

  def start_link() do
    {:ok, _pid} = GS.start_link(__MODULE__, %{request: [], response: []}, name: __MODULE__)
  end

  def add_request(method, request), do: GS.call(W, {:enqueue, :request, {method, request}})

  def pop_request(), do: GS.call(W, {:dequeue, :request})

  def add_response(response), do: GS.call(W, {:enqueue, :response, response})

  def pop_response(), do: GS.call(W, {:dequeue, :response})

  ### Server Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:enqueue, type, data}, _from, state) do
    state
    |> Map.get(type)
    |> List.insert_at(-1, prep(type, data))
    |> invoke({:reply, Enum.count(&1), state |> Map.put(type, &1)})
  end

  def handle_call({:dequeue, type}, _from, state) do
    state
    |> Map.get(type)
    |> case do
      [] -> {:reply, nil, state}
      [h | t] -> {:reply, h, state |> Map.put(type, t)}
    end
  end

  defp prep(:response, {:error, _} = response), do: response

  defp prep(:response, {num, data}) do
    %{body: nil, status_code: 200, headers: []}
    |> Map.merge(data)
    |> invoke({num, &1})
  end

  defp prep(_, response), do: response
end
