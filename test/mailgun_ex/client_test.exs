defmodule MailgunEx.ClientTest do
  use ExUnit.Case
  alias MailgunEx.{Client, BypassApi}

  setup do
    bypass = BypassApi.setup(domain: "namedb.org")
    on_exit fn ->
      BypassApi.teardown(domain: "namedb.org")
    end
    {:ok, bypass: bypass}
  end

  test "Send an email", %{bypass: bypass} do
    BypassApi.request(bypass, "POST", "/namedb.org/messages", 200, "messages.json")

    {ok, _} = Client.send_email(
           from: "sender@localhost",
           to: "receiver@localhost",
           subject: "My subject",
           text: "Hello World",
           html: "<b>Hellow</b> World")

    assert :ok == ok
  end

  test "Create a mailing list", %{bypass: bypass} do
    BypassApi.request(bypass, "POST", "/lists", 200, "new_mailing_list.json")

    {ok, _} = Client.new_mailing_list("app@namedb.org", name: "Test List")
    assert :ok == ok
  end

  test "Retrieve your mailing list", %{bypass: bypass} do
    BypassApi.request(bypass, "GET", "/lists/app@namedb.org", 200, "mailing_list.json")

    {ok, _} = Client.mailing_list("app@namedb.org")
    assert :ok == ok
  end

  test "Add to your mailing list", %{bypass: bypass} do
    BypassApi.request(bypass, "POST", "/lists", 200, "new_mailing_list.json")

    {ok, _} = Client.new_mailing_list("app@namedb.org", name: "Test List")
    assert :ok == ok
  end

  test "Add subscriber to a mailing list", %{bypass: bypass} do
    BypassApi.request(bypass, "POST", "/lists/app@namedb.org/members", 200, "add_subscriber.json")

    {ok, _} = Client.add_subscriber("app@namedb.org", "jamesurl@namedb.org", name: "Test List")
    assert :ok == ok
  end

  test "Delete a mailing list", %{bypass: bypass} do
    BypassApi.request(bypass, "DELETE", "/lists/app@namedb.org", 200, "delete_mailing_list.json")

    {ok, _} = Client.delete_mailing_list("app@namedb.org")
    assert :ok == ok
  end

  test "Delete a subscriber to a mailing list", %{bypass: bypass} do
    BypassApi.request(bypass, "DELETE", "/lists/app@namedb.org/members/jamesurl@namedb.org", 200, "remove_subscriber.json")

    {ok, _} = Client.remove_subscriber("app@namedb.org", "jamesurl@namedb.org")
    assert :ok == ok
  end

end
