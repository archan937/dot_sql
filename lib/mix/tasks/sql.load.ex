defmodule Mix.Tasks.Sql.Load do
  use Mix.Task

  def run(args) do
    "../../../mix_sql/priv/dot_sql"
    |> Path.expand(__DIR__)
    |> System.cmd(["load"] ++ args, into: IO.stream(:stdio, :line))
  end
end
