defmodule MailgunEx.ApiSimulateTest do
  use ExUnit.Case
  alias MailgunEx.{Api, Simulate}

  setup do
    Application.put_env(:mailgun_ex, :mode, :simulate)

    on_exit(fn ->
      Application.delete_env(:mailgun_ex, :mode)
    end)
  end

  test "GET /domains" do
    Simulate.add_response({:ok, %{body: "[\"a\"]", status_code: 200, headers: []}})

    {ok, data} =
      Api.request(
        :get,
        domain: nil,
        resource: "domains"
      )

    assert 200 == ok
    assert ["a"] == data
  end
end
