defmodule DotSql.MixProject do
  use Mix.Project

  def project do
    [
      app: :dot_sql,
      version: "0.1.0",
      elixir: "~> 1.6",
      escript: escript(),
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
    [
      {:poison, "~> 3.1"}
    ]
  end

  def escript do
    [
      main_module: DotSql.CLI,
      path: "mix_sql/priv/dot_sql"
    ]
  end
end
