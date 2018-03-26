defmodule MailgunEx.BypassApi do
  def request(bypass, method, endpoint, status, data_filename) do
    Bypass.expect_once(bypass, method, endpoint, fn conn ->
      Plug.Conn.resp(conn, status, File.read!("./test/fixtures/#{data_filename}"))
    end)
  end

  def setup(configs \\ []) do
    bypass = Bypass.open()
    Application.put_env(:mailgun_ex, :base, "http://localhost:#{bypass.port}")
    Enum.each(configs, fn {k, v} -> Application.put_env(:mailgun_ex, k, v) end)
    bypass
  end

  def teardown(configs \\ []) do
    Application.delete_env(:mailgun_ex, :base)
    Enum.each(configs, fn {k, _v} -> Application.delete_env(:mailgun_ex, k) end)
  end
end
