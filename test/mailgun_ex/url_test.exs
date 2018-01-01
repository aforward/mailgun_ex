defmodule MailgunEx.UrlTest do
  use ExUnit.Case
  alias MailgunEx.Url

  test "No configs, no problem" do
    assert "https://api.mailgun.net/v3/namedb.org" == Url.generate(domain: "namedb.org")
  end

end