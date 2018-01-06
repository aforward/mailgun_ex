defmodule MailgunEx.Api do

  @moduledoc"""
  Take several options, and an HTTP method and send the request to MailGun

  The available options are comprised of those to helper generate the MailGun
  URL, to extract data for the request and authenticate your API call.

  URL `opts` (to help create the resolved MailGun URL):
    * `:base` - The base URL which defaults to `https://api.mailgun.net/v3`
    * `:domain`  - The domain making the request (e.g. namedb.org)
    * `:resource` - The requested resource (e.g. /domains)

  Data `opts` (to send data along with the request)
    * `:body` - The encoded body of the request (typically provided in JSON)
    * `:params` - The query parameters of the request

  Header `opts` (to send meta-data along with the request)
    * `:api_key` - Defaults to the test API key `key-3ax6xnjp29jd6fds4gc373sgvjxteol0`
  """

  alias MailgunEx.{Content, Request, Response}

  @doc"""
  Issues an HTTP request with the given method to the given url_opts.

  Args:
    * `method` - HTTP method as an atom (`:get`, `:head`, `:post`, `:put`, `:delete`, etc.)
    * `opts` - A keyword list of options to help create the URL, provide the body and/or query params

  The options above can be defaulted using `Mix.Config` configurations,
  please refer to `MailgunEx` for more details on configuring this library.

  This function returns `{<status_code>, response}` if the request is successful, and
  `{:error, reason}` otherwise.

  ## Examples

      MailgunEx.Api.request(:get, resource: "domains")

  """
  def request(method, opts \\ []) do
    opts
    |> Request.create
    |> Request.send(method)
    |> Response.normalize
    |> Content.type
    |> Content.decode
  end

end