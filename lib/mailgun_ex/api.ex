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
      opts |> MailgunEx.Api.url,
      opts |> http_body,
      opts |> http_headers,
      opts |> http_opts
    )
    |> case do
        {:ok, %{body: raw_body, status_code: code, headers: headers}} ->
          {code, raw_body, headers}
        {:error, %{reason: reason}} -> {:error, reason, []}
       end
    |> content_type
    |> decode
  end

  @doc"""
  Extract the content type of the headers

  ## Examples

      iex> MailgunEx.Api.content_type({:ok, "<xml />", [{"Server", "GitHub.com"}, {"Content-Type", "application/xml; charset=utf-8"}]})
      {:ok, "<xml />", "application/xml"}

      iex> MailgunEx.Api.content_type([])
      "application/json"

      iex> MailgunEx.Api.content_type([{"Content-Type", "plain/text"}])
      "plain/text"

      iex> MailgunEx.Api.content_type([{"Content-Type", "application/xml; charset=utf-8"}])
      "application/xml"

      iex> MailgunEx.Api.content_type([{"Server", "GitHub.com"}, {"Content-Type", "application/xml; charset=utf-8"}])
      "application/xml"
  """
  def content_type({ok, body, headers}), do: {ok, body, content_type(headers)}
  def content_type([]), do: "application/json"
  def content_type([{ "Content-Type", val } | _]), do: val |> String.split(";") |> List.first
  def content_type([_ | t]), do: t |> content_type


  @doc"""
  Decode the response body

  ## Examples

      iex> MailgunEx.Api.decode({:ok, "{\\\"a\\\": 1}", "application/json"})
      {:ok, %{a: 1}}

      iex> MailgunEx.Api.decode({500, "", "application/json"})
      {500, ""}

      iex> MailgunEx.Api.decode({:error, "{\\\"a\\\": 1}", "application/json"})
      {:error, %{a: 1}}

      iex> MailgunEx.Api.decode({:ok, "{goop}", "application/json"})
      {:error, "{goop}"}

      iex> MailgunEx.Api.decode({:error, "{goop}", "application/json"})
      {:error, "{goop}"}

      iex> MailgunEx.Api.decode({:error, :nxdomain, "application/dontcare"})
      {:error, :nxdomain}

  """
  def decode({ok, body, _}) when is_atom(body), do: {ok, body}
  def decode({ok, "", _}), do: {ok, ""}
  def decode({ok, body, "application/json"}) when is_binary(body) do
    body
    |> Jason.decode(keys: :atoms)
    |> case do
         {:ok, parsed} -> {ok, parsed}
         _ -> {:error, body}
       end
  end
  def decode({ok, body, _}), do: {ok, body}

  defp http_headers(opts) do
    [
      {
        "Authorization",
        "Basic #{Base.encode64("api:#{opts[:api_key] || @test_apikey}")}"
      }
    ]
  end
  defp http_body(opts), do: opts[:body] || ""
  defp http_opts(opts), do: opts |> Keyword.drop([:base, :domain, :resource, :body, :api_key])

end