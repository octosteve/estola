defmodule Estola.MixProject do
  use Mix.Project

  def project do
    [
      app: :estola,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Estola.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:postgrex, ">= 0.0.1"},
      {:jason, "~> 1.0"},
      {:ecto, "~> 3.7.1"}
    ]
  end
end
