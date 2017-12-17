defmodule MailgunEx.BypassApi do

  def request(bypass, method, endpoint, status, data_filename) do
    Bypass.expect_once bypass, method, endpoint, fn conn ->
      Plug.Conn.resp(conn, status, File.read!("./test/fixtures/#{data_filename}"))
    end
  end

end