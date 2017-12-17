defmodule MailgunEx.ApiTest do
  use ExUnit.Case
  alias MailgunEx.{Api, BypassApi}

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass}
  end

  test "Make an invalid call to the Mailgun API" do
    {err, reason} = Api.request(:get, resource: "domains", base: "qtts://nowhere.local")
    assert :error == err
    assert :nxdomain == reason
  end

  @tag :external
  test "Make a live request to Mailgun API" do
    {ok, data} = Api.request(
                  :get,
                  resource: "domains",
                  api_key: "key-3ax6xnjp29jd6fds4gc373sgvjxteol0")
    assert 200 == ok
    File.mkdir_p("./test/fixtures")
    File.write("./test/fixtures/domains.json", data)
  end

  test "/domains", %{bypass: bypass} do
    BypassApi.request(bypass, "GET", "/domains", 200, "domains.json")
    {ok, _data} = Api.request(:get,
                    base: "http://localhost:#{bypass.port}",
                    resource: "domains")
    assert 200 == ok
  end
end
