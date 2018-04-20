defmodule MailgunEx.IgnoreTest do
  use ExUnit.Case

  alias MailgunEx.Request

  test "Always sunshine (GET, PUT, POST, DELETE all return 200)" do
    reply = %Request{mode: :ignore, url: "https://mailgun.local/domains"}
      |> Request.send(:get)
    assert reply == %{body: "ignored", status_code: 200, headers: []}
  end

  test "Create sunshine (POST returns 201)" do
    reply = %Request{mode: :ignore, url: "https://mailgun.local/domains"}
      |> Request.send(:post)
    assert reply == %{body: "ignored", status_code: 201, headers: []}
  end
end
