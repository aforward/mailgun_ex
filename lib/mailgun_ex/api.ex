defmodule MailgunEx.Api do

  @moduledoc """
  Direct HTTP Access To Mailgun API.
  """

  @base_url "https://api.mailgun.net/v3"
  @test_apikey "key-3ax6xnjp29jd6fds4gc373sgvjxteol0"

  @doc """
  The API url for your domain.

  Args:
    * `opts` - Keyword list of options

  Opts (`opts`):
    * `:base` - The base URL which defaults to `https://api.mailgun.net/v3`
    * `:domain`  - The domain making the request (e.g. namedb.org)
    * `:resource` - The requested resource (e.g. /domains)

  This function returns a fully qualified URL as a string.

  ## Example

      iex> MailgunEx.Api.url()
      "https://api.mailgun.net/v3"

      iex> MailgunEx.Api.url(base: "https://api.mailgun.net/v4")
      "https://api.mailgun.net/v4"

      iex> MailgunEx.Api.url(domain: "namedb.org")
      "https://api.mailgun.net/v3/namedb.org"

      iex> MailgunEx.Api.url(resource: "domains")
      "https://api.mailgun.net/v3/domains"

      iex> MailgunEx.Api.url(domain: "namedb.org", resource: "logs")
      "https://api.mailgun.net/v3/namedb.org/logs"

      iex> MailgunEx.Api.url(domain: "namedb.org", resource: "logs")
      "https://api.mailgun.net/v3/namedb.org/logs"

      iex> MailgunEx.Api.url(domain: "namedb.org", resource: ["tags", "t1", "stats"])
      "https://api.mailgun.net/v3/namedb.org/tags/t1/stats"

  """
  def url(opts \\ []) do
    [
      Keyword.get(opts, :base, @base_url),
      Keyword.get(opts, :domain),
      Keyword.get(opts, :resource, []),
    ]
    |> List.flatten
    |> Enum.reject(&is_nil/1)
    |> Enum.join("/")
  end


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

  This function returns `{<status_code>, response}` if the request is successful, and
  `{:error, reason}` otherwise.

  ## Examples

      MailgunEx.Api.request(:get, resource: "domains")

  """
  def request(method, opts \\ []) do
    HTTPoison.request(
      method,
      MailgunEx.Api.url(opts),
      opts[:body] || "",
      [
        {
          "Authorization",
          "Basic #{Base.encode64("api:#{opts[:api_key] || @test_apikey}")}"
        }
      ],
      opts |> Keyword.drop([:base, :domain, :resource, :body, :api_key])
    )
    |> (fn
         {:ok, %{status_code: status, body: body}} -> {status, body}
         {:error, reason} -> {:error, reason}
        end).()
  end

end