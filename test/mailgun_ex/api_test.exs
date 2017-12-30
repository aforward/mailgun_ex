defmodule MailgunEx.ApiTest do
  use ExUnit.Case
  alias MailgunEx.{Api, BypassApi}

  setup do
    bypass = Bypass.open

    on_exit fn ->
      Application.delete_env(:mailgun_ex, :base)
      Application.delete_env(:mailgun_ex, :api_key)
      Application.delete_env(:mailgun_ex, :http_opts)
    end

    {:ok, bypass: bypass}
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

  @tag :external
  test "Make a live request to Mailgun API" do
    {ok, data} = Api.request(
                  :get,
                  resource: "domains",
                  api_key: "key-3ax6xnjp29jd6fds4gc373sgvjxteol0")
    assert 200 == ok
    File.mkdir_p("./test/fixtures")
    File.write("./test/fixtures/domains.json", data)
  end

  test "/domains", %{bypass: bypass} do
    BypassApi.request(bypass, "GET", "/domains", 200, "domains.json")
    {ok, data} = Api.request(:get,
                    base: "http://localhost:#{bypass.port}",
                    resource: "domains")
    assert 200 == ok

    assert is_map(data)
    assert 5 == data[:total_count]
    assert 5 == data[:items] |> Enum.count
  end
end
