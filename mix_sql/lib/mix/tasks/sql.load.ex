defmodule Mix.Tasks.Sql.Load do
  use Mix.Task

  def run(args) do
    MixSql.run("load", args)
  end
end
