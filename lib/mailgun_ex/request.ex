defmodule MailgunEx.Request do
  @moduledoc """
  A structure to capture the request parameters to send to HTTPoision,
  this allows us to test the request without actually havig to
  send it; for ease (and speed) of testing.

  A `%Request{}` struct contains the following parts:

    * `url` - Where are we sending the request
    * `body` - What is the body of the request
    * `headers` - What headers are we sending
    * `mode` - We are :live, or :simulate
    * `http_opts` - All others configs, such as query `:params`

  """

  defstruct url: nil, body: "", headers: [], http_opts: [], mode: :live

  alias MailgunEx.{Request, Opts, Url, Simulate}

  @test_apikey "key-3ax6xnjp29jd6fds4gc373sgvjxteol0"

  @doc """
  Build a HTTP request based on the provided options, which comprise

  ## Example

      iex> MailgunEx.Request.create().mode
      :live

      iex> MailgunEx.Request.create(mode: :simulate).mode
      :simulate

      iex> MailgunEx.Request.create(domain: "namedb.org", resource: "logs").url
      "https://api.mailgun.net/v3/namedb.org/logs"

      iex> MailgunEx.Request.create(body: "What is life?").body
      "What is life?"

      iex> MailgunEx.Request.create(api_key: "key-abc123").headers
      [{"Authorization", "Basic #{Base.encode64("api:key-abc123")}"}]

      iex> MailgunEx.Request.create(params: [limit: 10], timeout: 1000).http_opts
      [params: [limit: 10], timeout: 1000]

  """
  def create(opts \\ []) do
    %Request{
      url: opts |> Url.generate(),
      mode: opts |> mode,
      body: opts |> http_body,
      headers: opts |> http_headers,
      http_opts: opts |> http_opts
    }
  end

  @doc """
  Send an HTTP request, there are two modes of sending.  If it's mode: :live,
  then we will use `HTTPoison` under the hood, so
  take a look at their API for additional configuration options.

  For example,

      %Request{url: "https://mailgun.local/domains"} |> Request.send(:get)

  On the other hand, if it's in mode: :simulate then we will just store
  the result (in MailgunEx.Simulate) and return the result (also from)
  MailgunEx.Simulate.

  To send a simulated request,

      MailgunEx.Simulate.add_response(:x)
      MailgunEx.Simulate.add_response({
        200,
        %{body: "[]", status_code: 200, headers: [{"Content-Type", "application/json"}]}
      })

      %Request{mode: :simulate, url: "https://mailgun.local/domains"}
      |> Request.send(:get)
  """
  def send(%Request{mode: :simulate} = request, method) do
    Simulate.add_request(method, request)

    case Simulate.pop_response() do
      nil ->
        raise "Missing a simulated response, make sure to add one using MailgunEx.Simulate.add_response"

      found ->
        found
    end
  end

  def send(%Request{mode: :live, url: url, body: body, headers: headers, http_opts: opts}, method) do
    HTTPoison.request(
      method,
      url,
      body,
      headers,
      opts
    )
  end

  defp mode(opts), do: opts |> Opts.merge([:mode]) |> Keyword.get(:mode, :live)

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
    |> Keyword.drop([:base, :mode, :domain, :resource, :body, :api_key])
    |> Opts.merge(:http_opts)
  end
end
