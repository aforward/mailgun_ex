defmodule MailgunEx.SandboxApi do

  def put_env(live_key) do
    case Application.get_env(:mailgun_ex, String.to_atom("sandbox_#{live_key}")) do
      nil -> raise "Missing test.exs :sandbox_#{live_key} config, look at ./config/test.example.exs for help"
      sandbox_val -> Application.put_env(:mailgun_ex, live_key, sandbox_val)
    end
  end

  def delete_env(live_key) do
    Application.delete_env(:mailgun_ex, live_key)
  end

end