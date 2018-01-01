defmodule MailgunEx.ApiTest do
  use ExUnit.Case
  alias MailgunEx.Api

  setup do
    on_exit fn ->
      Application.delete_env(:mailgun_ex, :base)
      Application.delete_env(:mailgun_ex, :api_key)
      Application.delete_env(:mailgun_ex, :http_opts)
    end
  end

  test "No configs, no problem" do
    assert "https://api.mailgun.net/v3/namedb.org" == Api.url(domain: "namedb.org")
  end


  test "Use configs for url if opts key not provided" do
    Application.put_env(:mailgun_ex, :base, "https://mailgun.local/v4")
    assert "https://mailgun.local/v4/namedb.org" == Api.url(domain: "namedb.org")
  end

  test "Use configs for http_headers if opts key not provided" do
    Application.put_env(:mailgun_ex, :api_key, "key-abc123")
    assert [
        {
          "Authorization",
          "Basic #{Base.encode64("api:key-abc123")}"
        }
      ] == Api.http_headers()
  end

  test "Override api_key and ignore config in http_headers" do
    Application.put_env(:mailgun_ex, :api_key, "key-abc123")
    assert [
        {
          "Authorization",
          "Basic #{Base.encode64("api:key-def456")}"
        }
      ] == Api.http_headers(api_key: "key-def456")
  end

  test "Use configs for https_opts if opts key not provided" do
    Application.put_env(:mailgun_ex, :http_opts, [timeout: 5000])
    assert [timeout: 5000, params: [limit: 10]] == Api.http_opts(params: [limit: 10])
  end

  test "Make an invalid call to the Mailgun API" do
    {err, reason} = Api.request(:get, resource: "domains", base: "qtts://nowhere.local")
    assert :error == err
    assert :nxdomain == reason
  end

end
