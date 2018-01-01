defmodule MailgunEx.ApiSandboxTest do
  use ExUnit.Case
  alias MailgunEx.{Api,SandboxApi}

  # In this file, we will be making live requests
  # to the Mailgun API, using the publically available
  # *test* key.  These tests will also write fixtures
  # to ./test/fixtures which will be used with the
  # stubbed out tests in MailgunEx.ApiBypassTest module

  setup do
    sandbox_keys = [:domain, :api_key, :from, :to]
    Enum.each(sandbox_keys,  &SandboxApi.put_env/1)
    on_exit fn ->
      Enum.each(sandbox_keys, &SandboxApi.delete_env/1)
    end
  end

  @tag :external
  test "GET /domains" do
    {ok, data} = Api.request(
                  :get,
                  domain: nil,
                  resource: "domains",
                  api_key: "key-3ax6xnjp29jd6fds4gc373sgvjxteol0")
    assert 200 == ok
    File.mkdir_p("./test/fixtures")
    File.write("./test/fixtures/domains.json", data |> Jason.encode!)
  end

  @tag :external
  test "POST /<domain>/messages" do
    {ok, data} = Api.request(
                   :post,
                   resource: "messages",
                   params: [
                     from: Application.get_env(:mailgun_ex, :from),
                     to: Application.get_env(:mailgun_ex, :to),
                     subject: "Hello From Test",
                     text: "Hello, from test.",
                     html: "<b>Hello</b>, from test.",
                   ])
    assert 200 == ok
    assert "Queued. Thank you." == data[:message]
    assert nil != data[:id]
    File.mkdir_p("./test/fixtures")
    File.write(
      "./test/fixtures/messages.json",
      data |> Jason.encode! |> SandboxApi.strip_email
    )
  end



end
