defmodule Mix.Tasks.Sql.Dump do
  use Mix.Task

  def run(args) do
    MixSql.run("dump", args)
  end
end
