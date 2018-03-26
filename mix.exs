defmodule MailgunEx.Mixfile do
  use Mix.Project

  @name :mailgun_ex
  @version "0.1.0"

  @deps [
    {:ex_doc, "> 0.0.0", only: [:dev, :test]},
    {:httpoison, "~> 1.0"},
    {:jason, "~> 1.0"},
    {:bypass, "~> 0.8", only: [:dev, :test]}
  ]

  @docs [
    main: "MailgunEx",
    extras: ["README.md"]
  ]

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app: @name,
      version: @version,
      elixir: ">= 1.6.0",
      deps: @deps,
      docs: @docs,
      build_embedded: in_production,
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      # built-in apps that need starting
      extra_applications: [
        :logger
      ]
    ]
  end
end
