defmodule MailgunEx.Api do

  @moduledoc """
  Direct HTTP Access To Mailgun API.
  """

  alias MailgunEx.{Content, Opts, Url}

  @test_apikey "key-3ax6xnjp29jd6fds4gc373sgvjxteol0"

  @doc"""
  Issues an HTTP request with the given method to the given url_opts.

  Args:
    * `method` - HTTP method as an atom (`:get`, `:head`, `:post`, `:put`, `:delete`, etc.)
    * `opts` - A keyword list of options to help create the URL, provide the body and/or query params

  URL `opts` (to help create the resolved MailGun URL):
    * `:base` - The base URL which defaults to `https://api.mailgun.net/v3`
    * `:domain`  - The domain making the request (e.g. namedb.org)
    * `:resource` - The requested resource (e.g. /domains)

  Data `opts` (to send data along with the request)
    * `:body` - The encoded body of the request (typically provided in JSON)
    * `:params` - The query parameters of the request

  Header `opts` (to send meta-data along with the request)
    * `:api_key` - Defaults to the test API key `key-3ax6xnjp29jd6fds4gc373sgvjxteol0`

  The options above can be defaulted using `Mix.Config` configurations,
  please refer to `MailgunEx` for more details on configuring this library.

  This function returns `{<status_code>, response}` if the request is successful, and
  `{:error, reason}` otherwise.

  ## Examples

      MailgunEx.Api.request(:get, resource: "domains")

  """
  def request(method, opts \\ []) do
    opts
    |> prepare_request
    |> send_request(method)
    |> case do
        {:ok, %{body: raw_body, status_code: code, headers: headers}} ->
          {code, raw_body, headers}
        {:error, %{reason: reason}} -> {:error, reason, []}
       end
    |> Content.type
    |> Content.decode
  end

  @doc false
  def prepare_request(opts \\ []) do
    [
      url: opts |> Url.generate,
      body: opts |> http_body,
      headers: opts |> http_headers,
      http_opts: opts |> http_opts
    ]
  end

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

  defp http_body(opts), do: opts[:body] || ""

  defp send_request([url: url, body: http_body, headers: headers, http_opts: http_opts], method) do
    HTTPoison.request(
      method,
      url,
      http_body,
      headers,
      http_opts
    )
  end

end