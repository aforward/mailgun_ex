defmodule MailgunEx.Url do
  @moduledoc """
  Generate the appropriate MailgunEx URL based on the sending
  domain, and the desired resource.
  """

  @base_url "https://api.mailgun.net/v3"

  alias MailgunEx.{Opts}

  @doc """
  The API url for your domain, configurable using several `opts`
  (Keyword list of options).

  ## Available options:

    * `:base` - The base URL which defaults to `https://api.mailgun.net/v3`
    * `:domain`  - The domain making the request (e.g. namedb.org)
    * `:resource` - The requested resource (e.g. /domains)

  The options above can be defaulted using `Mix.Config` configurations,
  please refer to `MailgunEx` for more details on configuring this library.

  This function returns a fully qualified URL as a string.

  ## Example

      iex> MailgunEx.Url.generate()
      "https://api.mailgun.net/v3"

      iex> MailgunEx.Url.generate(base: "https://api.mailgun.net/v4")
      "https://api.mailgun.net/v4"

      iex> MailgunEx.Url.generate(domain: "namedb.org")
      "https://api.mailgun.net/v3/namedb.org"

      iex> MailgunEx.Url.generate(resource: "domains")
      "https://api.mailgun.net/v3/domains"

      iex> MailgunEx.Url.generate(domain: "namedb.org", resource: "logs")
      "https://api.mailgun.net/v3/namedb.org/logs"

      iex> MailgunEx.Url.generate(domain: "namedb.org", resource: "tags/t1")
      "https://api.mailgun.net/v3/namedb.org/tags/t1"

      iex> MailgunEx.Url.generate(domain: "namedb.org", resource: ["tags", "t1", "stats"])
      "https://api.mailgun.net/v3/namedb.org/tags/t1/stats"

  """
  def generate(opts \\ []) do
    opts
    |> Opts.merge([:base, :domain, :resource])
    |> (fn all_opts ->
          [
            Keyword.get(all_opts, :base, @base_url),
            Keyword.get(all_opts, :domain),
            Keyword.get(all_opts, :resource, [])
          ]
        end).()
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.join("/")
  end
end
