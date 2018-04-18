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

  test "add_response, :send_email" do
    Simulate.add_response(:send_email)
    assert Simulate.pop_response() == {:ok, %{body: nil, headers: [], status_code: 200, id: "<acb123@simulate.mailgun.org>", message: "Queued. Thank you."}}
  end

end
