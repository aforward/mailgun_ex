defmodule MailgunEx.Application do
  @moduledoc false

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  use Application

  def start(_type, _args) do
    DeferredConfig.populate(:mailgun_ex)

    import Supervisor.Spec, warn: false

    children = [
      worker(MailgunEx.Simulate, [])
    ]

    opts = [
      strategy: :one_for_one,
      name: MailgunEx.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end
end
