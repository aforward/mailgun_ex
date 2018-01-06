defmodule MailgunEx.ApiTest do
  use ExUnit.Case
  alias MailgunEx.Api

  test "Make an invalid call to the Mailgun API" do
    {err, reason} = Api.request(:get, resource: "domains", base: "qtts://nowhere.local")
    assert :error == err
    assert :nxdomain == reason
  end

end
