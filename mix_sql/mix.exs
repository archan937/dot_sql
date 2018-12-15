defmodule MixSql.MixProject do
  use Mix.Project

  def project do
    [
      app: :mix_sql,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    []
  end
end
