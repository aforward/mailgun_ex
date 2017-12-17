defmodule MailgunEx.ApiTest do
  use ExUnit.Case
  alias MailgunEx.Api

  test "Make an invalid call to the Mailgun API" do
    {err, reason} = Api.request(:get, resource: "domains", base: "qtts://nowhere.local")
    assert :error == err
    assert :nxdomain == reason
  end

  @tag :external
  test "Make a live request to Mailgun API" do
    {ok, _data} = Api.request(
                  :get,
                  resource: "domains",
                  api_key: "key-3ax6xnjp29jd6fds4gc373sgvjxteol0")
    assert 200 == ok
  end

end
