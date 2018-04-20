A client API to the MailGun Email RESTful API.

You can sign up for a free account at:

    https://signup.mailgun.com/new/signup

And the latest API documentation is available at:

    https://documentation.mailgun.com/en/latest/

To access direct calls to the service, you will want to use the
`MailgunEx.Api` module.  When making requests, you can provide
several `opts`, all of which can be defaulted using `Mix.Config`.

Here is an example of how to configure this library

    config :mailgun_ex,
      base: "https://api.mailgun.net/v3",
      mode: :live,
      domain: "namedb.org",
      api_key: "key-3ax6xnjp29jd6fds4gc373sgvjxteol0",
      http_opts: %{
        timeout: 5000,
      }

The configs use a library called [Deferred Config](https://hex.pm/packages/deferred_config)
so that you can use environment variables that will be loaded at runtime, versus
compiled into the release.

Here's an example of how to use the system variables

    config :mailgun_ex,
      base: "https://api.mailgun.net/v3",
      mode: {:system, "MAILGUN_MODE", :live, {String, :to_atom}},
      domain: {:system, "MAILGUN_DOMAIN", "defaultname.com"} ,
      api_key: {:system, "MAILGUN_API_KEY"},
      http_opts: %{
        timeout: 5000,
      }

Our default `mix test` tests will use [Bypass](https://hex.pm/packages/bypass)
as the `base` service URL so that we will not hit your production MailGun
account during testing.

Here is an outline of all the configurations you can set.

  * `:base`      - The base URL which defaults to `https://api.mailgun.net/v3`
  * `:mode`      - Defaults to `:live`, but can be set to `:simulate` for testing, or `:ignore` for dev
  * `:domain`    - The domain making the request (e.g. namedb.org)
  * `:api_key`   - Your mailgun API key, which looks like `key-3ax6xnjp29jd6fds4gc373sgvjxteol0`
  * `:http_opts` - A passthrough map of options to send to HTTP request, more details below

This client library uses [HTTPoison](https://hex.pm/packages/httpoison)
for all HTTP communication, and we will pass through any `:http_opts` you provide,
which we have shown below.

  * `:timeout`          - timeout to establish a connection, in milliseconds. Default is 8000
  * `:recv_timeout`     - timeout used when receiving a connection. Default is 5000
  * `:stream_to`        - a PID to stream the response to
  * `:async`            - if given :once, will only stream one message at a time, requires call to stream_next
  * `:proxy`            - a proxy to be used for the request; it can be a regular url or a {Host, Port} tuple
  * `:proxy_auth`       - proxy authentication {User, Password} tuple
  * `:ssl`              - SSL options supported by the ssl erlang module
  * `:follow_redirect`  - a boolean that causes redirects to be followed
  * `:max_redirect`     - an integer denoting the maximum number of redirects to follow
  * `:params`           - an enumerable consisting of two-item tuples that will be appended to the url as query string parameters

If these are out of date, please push a Pull-Request to [mailgun_ex](https://github.com/work-samples/mailgun_ex)
"""

@doc """
Issues an HTTP request with the given method to the given url_opts.

Args:
  * `method` - HTTP method as an atom (`:get`, `:head`, `:post`, `:put`, `:delete`, etc.)
  * `opts` - A keyword list of options to help create the URL, provide the body and/or query params

The options above can be defaulted using `Mix.Config` configurations,
as documented above.

This function returns `{<status_code>, response}` if the request is successful, and
`{:error, reason}` otherwise.

## Installation

```elixir
@deps [
  mailgun_ex: "~> 0.2.7"
]
```

## Examples

    MailgunEx.request(:get, resource: "domains")

## License

MIT

