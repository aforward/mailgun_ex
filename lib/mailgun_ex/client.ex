defmodule MailgunEx.Client do
  alias MailgunEx.{Api, Opts}

  @moduledoc """
  Helper functions to access the MailGun API in a
  more succinct way.  If any features of the API are
  not directly available here, then consider using
  the `MailgunEx.Api` module directly, or raising a PR
  to add them to the client.

  All client functions includes a `opts` argument that
  can accept any lower level options including those
  for `&MailgunEx.Api.request/2`

  Here is an outline of all the configurations you can set.

    * `:base`      - The base URL which defaults to `https://api.mailgun.net/v3`
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

  If the above values do not change between calls, then consider configuring
  them with `Mix.Config` to avoid using them throughout your code.
  """

  @doc """
  Send an email.

  Options (`opts`):
    * `:to` - The recipient of the email
    * `:subject` - The subject of the email
    * `:from` - The sender of the email
    * `:text` - The body of the email, in TEXT
    * `:html` - The body of the email, but in HTML format

  You can provide Application env defaults for the `:to` and `:from` values,
  such as

      config :mailgun_ex,
        to: "app@namedb.org",
        from: "app@namebd.org"

  In this case, you can omit the `:from` keyword from my function call.
  If you do provide one, then it will override the defaults above.

  Conversly, if you want to route all emails to a specific inbox regardless
  of what the function provides, then configure a `:test_to` and `:test_from`
  Application env vales.  Such as,

      config :mailgun_ex,
        test_to: "app+TESTING@namedb.org",
        test_from: "app+TESTING@namebd.org"
  """
  def send_email(opts \\ []) do
    [
      resource: "messages",
      params: [
        from: resolve(opts, :from),
        to: resolve(opts, :to),
        subject: opts[:subject],
        text: opts[:text],
        html: opts[:html]
      ]
    ]
    |> send_request(:post)
  end

  @doc """
  Retrieve information about a mailing for `sender`.
  """
  def mailing_list(sender) do
    [
      resource: ["lists", sender],
      domain: nil
    ]
    |> send_request(:get)
  end

  @doc """
  Create a new mailing list
  """
  def new_mailing_list(sender, opts \\ []) do
    [
      resource: "lists",
      domain: nil,
      params: [
        address: sender,
        name: opts[:name],
        description: opts[:description],
        access_level: opts[:access_level]
      ]
    ]
    |> send_request(:post)
  end

  @doc """
  Delete a mailing list
  """
  def delete_mailing_list(sender) do
    [
      resource: ["lists", sender],
      domain: nil
    ]
    |> send_request(:delete)
  end

  @doc """
  Add a subscriber to your mailing list
  """
  def add_subscriber(sender, subscriber, opts \\ []) do
    [
      resource: ["lists", sender, "members"],
      domain: nil,
      params: [
        address: subscriber,
        name: opts[:name],
        vars: Jason.encode!(opts[:vars]),
        subscribed: opts[:subscribed] || "yes",
        upsert: opts[:upsert] || "yes"
      ]
    ]
    |> send_request(:post)
  end

  @doc """
  Remove a subscriber from your mailing list
  """
  def remove_subscriber(sender, subscriber) do
    [
      resource: ["lists", sender, "members", subscriber],
      domain: nil
    ]
    |> send_request(:delete)
  end

  defp send_request(request_opts, method) do
    method
    |> Api.request(request_opts)
    |> case do
      {200, data} -> {:ok, data}
      err -> err
    end
  end

  defp resolve(opts, key) do
    override_key = "test_#{key}" |> String.to_atom()
    Opts.env(override_key) || opts[key] || Opts.env(key)
  end
end
