defmodule MailgunEx.Content do
  @moduledoc"""
  Transform, decode and analyze raw encoded content based on it's type
  (e.g. decode a raw JSON string into an Elixir map)
  """

  @doc"""
  Extract the content type of the headers

  ## Examples

      iex> MailgunEx.Content.type({:ok, "<xml />", [{"Server", "GitHub.com"}, {"Content-Type", "application/xml; charset=utf-8"}]})
      {:ok, "<xml />", "application/xml"}

      iex> MailgunEx.Content.type([])
      "application/json"

      iex> MailgunEx.Content.type([{"Content-Type", "plain/text"}])
      "plain/text"

      iex> MailgunEx.Content.type([{"Content-Type", "application/xml; charset=utf-8"}])
      "application/xml"

      iex> MailgunEx.Content.type([{"Server", "GitHub.com"}, {"Content-Type", "application/xml; charset=utf-8"}])
      "application/xml"
  """
  def type({ok, body, headers}), do: {ok, body, type(headers)}
  def type([]), do: "application/json"
  def type([{ "Content-Type", val } | _]), do: val |> String.split(";") |> List.first
  def type([_ | t]), do: t |> type

  @doc"""
  Decode the response body

  ## Examples

      iex> MailgunEx.Content.decode({:ok, "{\\\"a\\\": 1}", "application/json"})
      {:ok, %{a: 1}}

      iex> MailgunEx.Content.decode({500, "", "application/json"})
      {500, ""}

      iex> MailgunEx.Content.decode({:error, "{\\\"a\\\": 1}", "application/json"})
      {:error, %{a: 1}}

      iex> MailgunEx.Content.decode({:ok, "{goop}", "application/json"})
      {:error, "{goop}"}

      iex> MailgunEx.Content.decode({:error, "{goop}", "application/json"})
      {:error, "{goop}"}

      iex> MailgunEx.Content.decode({:error, :nxdomain, "application/dontcare"})
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

end