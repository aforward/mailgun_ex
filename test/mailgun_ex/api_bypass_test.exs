defmodule MailgunEx.ApiBypassTest do
  use ExUnit.Case
  alias MailgunEx.{Api, BypassApi}

  # In this file, we will be making stubbed out requests
  # to a local *bypass* server*.  These tests will load
  # fixtures from ./test/fixtures which have been generated
  # by running the MailgunEx.ApiSandboxTest module tests
  # Most tests here should have an associated live test
  # (where possible) so that we can assert data as close
  # to the real thing as often as possible.

  setup do
    bypass = Bypass.open
    Application.put_env(:mailgun_ex, :base, "http://localhost:#{bypass.port}")
    on_exit fn ->
      Application.delete_env(:mailgun_ex, :base)
    end
    {:ok, bypass: bypass}
  end

  test "GET /domains", %{bypass: bypass} do
    BypassApi.request(bypass, "GET", "/domains", 200, "domains.json")
    {ok, data} = Api.request(:get, resource: "domains")
    assert 200 == ok

    assert is_map(data)
    assert 5 == data[:total_count]
    assert 5 == data[:items] |> Enum.count
  end

  test "POST /<domain>/messages", %{bypass: bypass} do
    BypassApi.request(bypass, "POST", "/myapp.local/messages", 200, "messages.json")

    {ok, data} = Api.request(
                   :post,
                   domain: "myapp.local",
                   resource: "messages",
                   params: [
                     from: "me@myapp.local",
                     to: "me@myapp.local",
                     subject: "Hello From Test",
                     text: "Hello, from test.",
                     html: "<b>Hello</b>, from test.",
                   ])
    assert 200 == ok
    assert "Queued. Thank you." == data[:message]
    assert "<201801010000000.1.ABC123@sandbox123.mailgun.org>" == data[:id]
  end

end
