use Mix.Config

# Here is an example of how to configure this library
#
# config :mailgun_ex,
#  base: "https://api.mailgun.net/v3",
#  domain: "namedb.org",
#  api_key: "key-3ax6xnjp29jd6fds4gc373sgvjxteol0",
#  http_opts: %{
#    timeout: 5000,
#  }
#
# Our default `mix test` tests will use [Bypass](https://hex.pm/packages/bypass)
# as the `base` service URL so that we will not hit your production MailGun
# account during testing.
#
# Here is an outline of all the configurations you can set.
#
#   * `:base`      - The base URL which defaults to `https://api.mailgun.net/v3`
#   * `:domain`    - The domain making the request (e.g. namedb.org)
#   * `:api_key`   - Your mailgun API key, which looks like `key-3ax6xnjp29jd6fds4gc373sgvjxteol0`
#   * `:http_opts` - A passthrough map of options to send to HTTP request, more details below
#
# This client library uses [HTTPoison](https://hex.pm/packages/httpoison)
# for all HTTP communication, and we will pass through any `:http_opts` you provide,
# which we have shown below.
#
#   * `:timeout`          - timeout to establish a connection, in milliseconds. Default is 8000
#   * `:recv_timeout`     - timeout used when receiving a connection. Default is 5000
#   * `:stream_to`        - a PID to stream the response to
#   * `:async`            - if given :once, will only stream one message at a time, requires call to stream_next
#   * `:proxy`            - a proxy to be used for the request; it can be a regular url or a {Host, Port} tuple
#   * `:proxy_auth`       - proxy authentication {User, Password} tuple
#   * `:ssl`              - SSL options supported by the ssl erlang module
#   * `:follow_redirect`  - a boolean that causes redirects to be followed
#   * `:max_redirect`     - an integer denoting the maximum number of redirects to follow
#   * `:params`           - an enumerable consisting of two-item tuples that will be appended to the url as query string parameters
#
# If these are out of date, please push a Pull-Request to [mailgun_ex](https://github.com/work-samples/mailgun_ex)


# To run `@tag :external` tests, you will need to provide a local
# ./config/test.exs file, take a look at ./config/test.example.exs
# for more details about what that needs to look like.
if File.exists?("./config/#{Mix.env}.exs") do
  import_config "#{Mix.env}.exs"
end


