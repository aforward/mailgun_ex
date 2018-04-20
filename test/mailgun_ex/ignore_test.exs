defmodule MailgunEx.IgnoreTest do
  use ExUnit.Case

  alias MailgunEx.Request

  test "Send an email" do
    reply = MailgunEx.send_email(mode: :ignore)
    assert reply  == {:ok, "Mailgun Magnificent API"}
  end

  test "Always sunshine (GET, PUT, POST, DELETE all return 200)" do
    reply = %Request{mode: :ignore, url: "https://mailgun.local/domains"}
      |> Request.send(:get)
    assert reply == {:ok, %{body: "ignored", status_code: 200, headers: []}}
  end

  test "Also sunshine (POST returns 200)" do
    reply = %Request{mode: :ignore, url: "https://mailgun.local/domains"}
      |> Request.send(:post)
    assert reply == {:ok, %{body: "ignored", status_code: 200, headers: []}}
  end
end
