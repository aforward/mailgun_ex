defmodule MailgunEx.Request do
  @moduledoc"""
  A structure to capture the request parameters to send to HTTPoision,
  this allows us to test the request without actually havig to
  send it; for ease (and speed) of testing.

  A `%Request{}` struct contains the following parts:

    * `url` - Where are we sending the request
    * `body` - What is the body of the request
    * `headers` - What headers are we sending
    * `http_opts` - All others configs, such as query `:params`

  """

  defstruct url: nil, body: "", headers: [], http_opts: []

  alias MailgunEx.{Request, Opts, Url}

  @test_apikey "key-3ax6xnjp29jd6fds4gc373sgvjxteol0"

  @doc"""
  Build a HTTP request based on the provided options, which comprise

  ## Example

      iex> MailgunEx.Request.create(domain: "namedb.org", resource: "logs").url
      "https://api.mailgun.net/v3/namedb.org/logs"

      iex> MailgunEx.Request.create(body: "What is life?").body
      "What is life?"

      iex> MailgunEx.Request.create(api_key: "key-abc123").headers
      [{"Authorization", "Basic #{Base.encode64("api:key-abc123")}"}]

      iex> MailgunEx.Request.create(params: [limit: 10], timeout: 1000).http_opts
      [params: [limit: 10], timeout: 1000]

  """
  def create(opts  \\ []) do
    %Request{
      url: opts |> Url.generate,
      body: opts |> http_body,
      headers: opts |> http_headers,
      http_opts: opts |> http_opts
    }
  end

  @doc"""
  Send an HTTP request, this will use `HTTPoison` under the hood, so
  take a look at their API for additional configuration options.

  For example,

      %Request{url: "https://mailgun.local/domains"} |> Request.send(:get)
  """
  def send(%Request{url: url, body: body, headers: headers, http_opts: opts}, method) do
    HTTPoison.request(
      method,
      url,
      body,
      headers,
      opts
    )
  end

  defp http_body(opts), do: opts[:body] || ""

  defp http_headers(opts) do
    opts
    |> Opts.merge([:api_key])
    |> Keyword.get(:api_key, @test_apikey)
    |> (fn api_key ->
          [
            {
              "Authorization",
              "Basic #{Base.encode64("api:#{api_key}")}"
            }
          ]
        end).()
  end

  defp http_opts(opts) do
    opts
    |> Keyword.drop([:base, :domain, :resource, :body, :api_key])
    |> Opts.merge(:http_opts)
  end

end