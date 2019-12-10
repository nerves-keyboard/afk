defmodule AFK.MixProject do
  @moduledoc false

  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/doughsay/afk"

  def project do
    [
      app: :afk,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    A library for modeling the internal state of a computer keyboard
    """
  end

  defp package do
    [
      files: ["lib", ".formatter.exs", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Chris Dosé <chris.dose@gmail.com>"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Readme" => "#{@source_url}/blob/#{@version}/README.md"
      }
    ]
  end

  defp docs do
    [
      source_ref: @version,
      source_url: @source_url,
      extras: [
        "README.md": [title: "README"],
        "LICENSE.md": [title: "LICENSE"]
      ]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end
end
