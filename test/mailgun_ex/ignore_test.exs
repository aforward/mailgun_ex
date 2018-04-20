defmodule MailgunEx.IgnoreTest do
  use ExUnit.Case

  alias MailgunEx.Request

  test "Always sunshine" do
    reply = %Request{mode: :ignore, url: "https://mailgun.local/domains"}
      |> Request.send(:get)
    assert reply == {200, :ignored}
  end
end
