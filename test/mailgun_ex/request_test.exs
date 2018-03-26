defmodule MailgunEx.RequestTest do
  use ExUnit.Case

  alias MailgunEx.Request

  setup do
    on_exit(fn ->
      Application.delete_env(:mailgun_ex, :base)
      Application.delete_env(:mailgun_ex, :api_key)
      Application.delete_env(:mailgun_ex, :http_opts)
    end)
  end

  test "Use configs for url if opts key not provided" do
    Application.put_env(:mailgun_ex, :base, "https://mailgun.local/v4")
    assert "https://mailgun.local/v4/namedb.org" == Request.create(domain: "namedb.org").url
  end

  test "Use configs for http_headers if opts key not provided" do
    Application.put_env(:mailgun_ex, :api_key, "key-abc123")

    assert [
             {
               "Authorization",
               "Basic #{Base.encode64("api:key-abc123")}"
             }
           ] == Request.create().headers
  end

  test "Override api_key and ignore config in http_headers" do
    Application.put_env(:mailgun_ex, :api_key, "key-abc123")

    assert [
             {
               "Authorization",
               "Basic #{Base.encode64("api:key-def456")}"
             }
           ] == Request.create(api_key: "key-def456").headers
  end

  test "Use configs for https_opts if opts key not provided" do
    Application.put_env(:mailgun_ex, :http_opts, timeout: 5000)
    assert [timeout: 5000, params: [limit: 10]] == Request.create(params: [limit: 10]).http_opts
  end

  test "Send an invalid request" do
    assert {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}} ==
             Request.send(%Request{url: "qtts://nowhere.local/domains"}, :get)
  end

  test "Send an valid request" do
    {:ok, %HTTPoison.Response{} = resp} =
      Request.send(
        %Request{url: "https://raw.githubusercontent.com/work-samples/mailgun_ex/master/LICENSE"},
        :get
      )

    assert 200 == resp.status_code
  end
end
