defmodule MailgunEx.SimulateTest do
  use ExUnit.Case
  alias MailgunEx.Simulate

  test "add_response, provide defaults to the response" do
    Simulate.add_response({200, %{}})
    assert Simulate.pop_response() == {200, %{body: nil, status_code: 200, headers: []}}
  end

  test "add_response, set all values" do
    Simulate.add_response({200, %{body: "a", status_code: 201, headers: [{"x", "y"}]}})
    assert Simulate.pop_response() == {200, %{body: "a", status_code: 201, headers: [{"x", "y"}]}}
  end
end
