defmodule MailgunEx.ApiSandboxTest do
  use ExUnit.Case
  alias MailgunEx.Api

  # In this file, we will be making live requests
  # to the Mailgun API, using the publically available
  # *test* key.  These tests will also write fixtures
  # to ./test/fixtures which will be used with the
  # stubbed out tests in MailgunEx.ApiBypassTest module

  @tag :external
  test "GET /domains" do
    {ok, data} = Api.request(
                  :get,
                  resource: "domains",
                  api_key: "key-3ax6xnjp29jd6fds4gc373sgvjxteol0")
    assert 200 == ok
    File.mkdir_p("./test/fixtures")
    File.write("./test/fixtures/domains.json", data)
  end

end
