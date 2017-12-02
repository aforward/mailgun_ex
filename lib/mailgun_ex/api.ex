defmodule MailgunEx.Api do

  @moduledoc """
  Direct HTTP Access To Mailgun API.
  """

  @base_url "https://api.mailgun.net/v3"

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

end