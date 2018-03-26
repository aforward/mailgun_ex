defmodule MailgunEx.OptsTest do
  use ExUnit.Case
  alias MailgunEx.Opts

  test "merge grabs all keys" do
    assert [a: 1, c: 3, b: "oranges"] ==
             Opts.merge([b: "oranges"], [a: 1, b: "apples", c: 3], nil)
  end

  test "merge grabs only desired keys" do
    assert [a: 1, b: "oranges"] ==
             Opts.merge([b: "oranges"], [a: 1, b: "apples", c: 3], [:a, :b, :x])
  end

  test "merge, ensure that nil is kept if provided" do
    assert [b: nil] == Opts.merge([b: nil], b: "apples")
  end

  test "merge, ensure that nil configured_keys returns the provided exactly" do
    assert [b: "oranges"] == Opts.merge([b: "oranges"], nil)
  end
end
