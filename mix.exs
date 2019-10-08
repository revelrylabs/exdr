defmodule XDR.MixProject do
  @moduledoc """
  Elixir XDR project configuration
  """
  use Mix.Project

  @github "https://github.com/revelrylabs/exdr"

  def project do
    [
      app: :exdr,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      elixirc_paths: elixirc_paths(Mix.env),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      package: package(),

      #docs
      name: "Elixir XDR",
      source_url: @github,
      homepage_url: @github,
      docs: [
        main: "README",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.11.2", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE", "CHANGELOG.md"],
      description: "Library for working with XDR in Elixir",
      maintainers: ["Jason Pollentier", "Revelry"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @github
      }
    ]
  end
end
