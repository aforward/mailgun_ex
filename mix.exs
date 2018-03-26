defmodule MailgunEx.Mixfile do
  use Mix.Project

  @app :mailgun_ex
  @git_url "https://github.com//aforward/mailgun_ex"
  @home_url @git_url
  @version "0.2.0"

  @deps [
    {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
    {:jason, "~> 1.0"},
    {:httpoison, "~> 1.0"},
    {:fn_expr, "~> 0.2"},
    {:version_tasks, "~> 0.10"},
    {:bypass, "~> 0.8", only: [:dev, :test]},
    {:ex_doc, "> 0.0.0", only: [:dev, :test]}
  ]

  @docs [
    main: "MailgunEx",
    extras: ["README.md"]
  ]

  @aliases [
  ]

  @package [
    name: @app,
    files: ["lib", "mix.exs", "README*", "LICENSE*"],
    maintainers: ["Andrew Forward"],
    licenses: ["MIT"],
    links: %{"GitHub" => @git_url}
  ]

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app:     @app,
      version: @version,
      elixir: ">= 1.6.0",
      name: @app,
      description: "A Mailgun API for Elixir",
      package: @package,
      source_url: @git_url,
      homepage_url: @home_url,
      docs: @docs,
      build_embedded:  in_production,
      start_permanent:  in_production,
      deps:    @deps,
      aliases: @aliases,
      elixirc_paths: elixirc_paths(Mix.env),
    ]
  end

  def application do
    [
      mod: {MailgunEx.Application, []},
      extra_applications: [
        :logger
      ]
    ]
  end
end
