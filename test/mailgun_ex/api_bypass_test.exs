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
    {:ok, bypass: bypass}
  end

  test "GET /domains", %{bypass: bypass} do
    BypassApi.request(bypass, "GET", "/domains", 200, "domains.json")
    {ok, data} = Api.request(:get,
                    base: "http://localhost:#{bypass.port}",
                    resource: "domains")
    assert 200 == ok

    assert is_map(data)
    assert 5 == data[:total_count]
    assert 5 == data[:items] |> Enum.count
  end
end
