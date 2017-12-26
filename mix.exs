defmodule MailgunEx.Mixfile do
  use Mix.Project

  @name    :mailgun_ex
  @version "0.1.0"

  @deps [
    { :ex_doc,  "> 0.0.0", only: [ :dev, :test ] },
    { :httpoison, "~> 0.13.0" },
    { :jason, "~> 1.0.0-rc.1" },
    { :bypass, "~> 0.8", only: [ :dev, :test ] },
  ]

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env == :prod
    [
      app:     @name,
      version: @version,
      elixir:  ">= 1.5.2",
      deps:    @deps,
      build_embedded:  in_production,
      elixirc_paths: elixirc_paths(Mix.env)
    ]
  end

  def application do
    [
      extra_applications: [         # built-in apps that need starting
        :logger
      ],
    ]
  end

end
